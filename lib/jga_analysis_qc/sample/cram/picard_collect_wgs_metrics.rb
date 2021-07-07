# frozen_string_literal: true

require 'pathname'

require_relative '../../chr_region'
require_relative '../../report/table'

module JgaAnalysisQC
  class Sample
    class Cram
      class PicardCollectWgsMetrics
        # For the definition of each metrics, see
        # https://broadinstitute.github.io/picard/picard-metric-definitions.html

        class CoverageStats
          # @return [Float]
          attr_reader :mean, :sd, :median, :mad

          def initialize(mean, sd, median, mad)
            @mean = mean
            @sd = sd
            @median = median
            @mad = mad
          end
        end

        class PercentExcluded
          FIELDS = %i[adapter mapq dupe unpaired baseq overlap capped total].freeze

          # @return [Float]
          attr_reader(*FIELDS)

          def initialize(**params)
            FIELDS.each { |k| instance_variable_set("@#{k}", params[k]) }
          end
        end

        class HetSnp
          # @return [Float]
          attr_reader :sensitivity

          # @return [Integer]
          attr_reader :q

          def initialize(sensitivity, q)
            @sensitivity = sensitivity
            @q = q
          end
        end

        # @return [Pathname]
        attr_reader :path

        # @return [ChrRegion]
        attr_reader :chr_region

        # @return [String]
        attr_reader :command_log

        # @return [Integer]
        attr_reader :territory

        # @return [CoverageStats]
        attr_reader :coverage_stats

        # @return [Hash{Integer => Float }] coverage -> percent
        attr_reader :percent_coverage

        # @return [HetSnp]
        attr_reader :het_snp

        # @return [Hash{ Integer => Integer }] coverage -> count
        attr_reader :histogram

        def initialize(path,
                       chr_region,
                       command_log,
                       territory,
                       coverage_stats,
                       percent_excluded,
                       percent_coverage,
                       het_snp,
                       histogram)
          @path = path
          @chr_region = chr_region
          @command_log = command_log
          @territory = territory
          @coverage_stats = coverage_stats
          @percent_excluded = percent_excluded
          @percent_coverage = percent_coverage
          @het_snp = het_snp
          @histogram = histogram
        end

        # @return [Report::Table]
        def path_table
          Report::Table.file_table(@path, 'metrics file')
        end

        # @return [Report::Table]
        def territory_table
          header = ['genome territory (bp)']
          type = [:integer]
          rows = [[@territory]]
          Report::Table.new(header, rows, type)
        end

        # @return [Report::Table]
        def coverage_stats_table
          desc = %w[mean median SD MAD]
          coverage = desc.map { |k| @coverage_stats.send(k.downcase) }
          header = %w[statistic coverage]
          rows = [desc, coverage].transpose
          type = %i[string float]
          Report::Table.new(header, rows, type)
        end

        # @return [Report::Table]
        def percent_excluded_table
          desc = %w[mapQ dupe unpaired baseQ overlap capped total]
          excluded = desc.map do |k|
            @percent_excluded.send(k.downcase) * 100
          end
          header = ['filter type', 'excluded (%)']
          rows = [desc, excluded].transpose
          type = [:string, Report::Table::FloatFormatter.new('.4')]
          Report::Table.new(header, rows, type)
        end

        # @return [Report::Table]
        def percent_coverage_table
          header = ['coverage', 'fraction (%)']
          rows = @percent_coverage.transform_values { |percent| percent * 100 }
          type = [:integer, Report::Table::FloatFormatter.new('.4')]
          Report::Table.new(header, rows, type)
        end

        # @return [Report::Table]
        def het_snp_table
          header = ['HET SNP sensitivity', 'HET SNP sensitivity Q']
          type = %i[float integer]
          rows = [[@het_snp.sensitivity, @het_snp.q]]
          Report::Table.new(header, rows, type)
        end

        class << self
          # @param picard_collect_wgs_metrics_path [Pathname]
          # @param chr_region                      [ChrRegion]
          # @return                                [PicardCollectWgsMetrics, nil]
          def parse(picard_collect_wgs_metrics_path, chr_region)
            return nil unless picard_collect_wgs_metrics_path.exist?

            lines = File.readlines(picard_collect_wgs_metrics_path, chomp: true)
            sections = split_by_section(lines)
            command_log = sections.select do |section|
              section.java_type == 'htsjdk.samtools.metrics.StringHeader'
            end.map(&:content).join("\n")
            metrics_section, histogram_section = ['METRICS CLASS', 'HISTOGRAM'].map do |title|
              sections.find { |section| section.title == title }
            end
            metrics_section_values = parse_metrics_section(metrics_section)
            histogram = parse_histogram_section(histogram_section)
            args = [
              picard_collect_wgs_metrics_path,
              chr_region,
              command_log,
              metrics_section_values,
              histogram
            ].flatten
            PicardCollectWgsMetrics.new(*args)
          end

          private

          class Section
            # @return [String, nil]
            attr_reader :title

            # @return [String]
            attr_reader :java_type

            # @return [String]
            attr_reader :content

            def initialize(title, java_type, content)
              @title = title
              @java_type = java_type
              @content = content
            end
          end

          # @param lines [Array<String>] lines from picard-CollectWgsMetrics output
          # @param sym   [Symbol]
          # @return      [Array<Section>]
          def split_by_section(lines, sym = '##')
            regexp = /^#{Regexp.escape(sym)}\s*(?:(.+)\t)?(.+)\s*$/
            lines.slice_before(regexp).map do |chunk|
              chunk.reject! { |line| line =~ /^\s*$/ }
              chunk.shift =~ regexp
              Section.new(Regexp.last_match(1), Regexp.last_match(2), chunk.join("\n"))
            end
          end

          # @param str [String]
          # @return    [CSV::Table]
          def parse_tsv(str)
            CSV.parse(
              str,
              col_sep: "\t",
              headers: true,
              converters: :numeric,
              header_converters: :symbol
            )
          end

          # @param section [Seciton]
          # @return        [Array] territory,
          #                        coverage stats,
          #                        percent excluded,
          #                        percent coverage, and
          #                        het snp
          def parse_metrics_section(section)
            row = parse_tsv(section.content).first
            territory = row[:genome_territory]
            coverage_stats = PicardCollectWgsMetrics::CoverageStats.new(
              *row.values_at(*%w[mean sd median mad].map { |k| :"#{k}_coverage" })
            )
            percent_excluded = parse_percent_excluded(row)
            percent_coverage = row.filter_map do |k, v|
              [Regexp.last_match(1).to_i, v] if k =~ /^pct_(\d+)x$/
            end.to_h
            het_snp = PicardCollectWgsMetrics::HetSnp.new(
              *row.values_at(*%w[sensitivity q].map { |k| :"het_snp_#{k}" })
            )
            [territory, coverage_stats, percent_excluded, percent_coverage, het_snp]
          end

          # @param row [CSV::Row]
          # @return    [PicardCollectWgsMetrics::PercentExcluded]
          def parse_percent_excluded(row)
            params =
              PicardCollectWgsMetrics::PercentExcluded::FIELDS.map.to_h do |k|
                [k, row[:"pct_exc_#{k}"]]
              end
            PicardCollectWgsMetrics::PercentExcluded.new(**params)
          end

          # @param section [Seciton]
          # @return        [Hash{ Integer => Integer }] coverage -> count
          def parse_histogram_section(section)
            parse_tsv(section.content).map.to_h do |row|
              %i[coverage high_quality_coverage_count].map { |k| row[k] }
            end
          end
        end
      end
    end
  end
end
