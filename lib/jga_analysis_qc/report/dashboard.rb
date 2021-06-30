# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/hash/indifferent_access'
require 'pathname'
require 'fileutils'
require 'open3'

require_relative '../settings'
require_relative '../chr_region'
require_relative 'render'
require_relative '../sample'
require_relative 'c3js'

module JgaAnalysisQC
  module Report
    class Dashboard
      TEMPLATE_PREFIX = 'dashboard'
      COVERAGE_STATS_TYPES = {
        mean: 'mean', sd: 'SD', median: 'median', mad: 'MAD'
      }.freeze
      X_AXIS_LABEL_HEIGHT = 100

      # @param result_dir [Pathname]
      # @param samples    [Array<Sample>]
      def initialize(result_dir, samples)
        @result_dir = result_dir
        @samples = samples.sort_by(&:end_time).reverse
        @sample_col = C3js::Column.new(:sample_name, 'sample name')
        @default_chart_params = {
          x: @sample_col,
          x_axis_label_height: X_AXIS_LABEL_HEIGHT
        }
      end

      # @return [Pathname] HTML path
      def render
        [D3_JS_PATH, C3_JS_PATH, C3_CSS_PATH].each do |src_path|
          Render.copy_file(src_path, @result_dir)
        end
        autosome_PAR_mean_coverage_plot_path =
          plot_autosome_PAR_mean_coverage(@result_dir)
        Render.run(
          TEMPLATE_PREFIX,
          @result_dir,
          binding,
          toc_nesting_level: DASHBOARD_TOC_NESTING_LEVEL
        )
      end

      private

      # @return [C3js::Data]
      def ts_tv_ratio
        @samples.flat_map do |sample|
          sample.vcf_collection.vcfs.map do |vcf|
            {
              sample_name: sample.name,
              chr_region: vcf.chr_region,
              ts_tv_ratio: vcf.bcftools_stats&.ts_tv_ratio
            }
          end
        end.then { |a| C3js::Data.new(a) }
      end

      # @return [Hash{ ChrRegion => String }]
      def ts_tv_ratio_html
        tstv_col = C3js::Column.new(:ts_tv_ratio, 'ts/tv')
        ts_tv_ratio.then do |data|
          HAPLOTYPECALLER_REGIONS.map.to_h do |chr_region|
            html = data.select(chr_region: chr_region)
                     .bar_chart_html(
                       @sample_col,
                       tstv_col,
                       bindto: "tstv_#{chr_region.id}",
                       **@default_chart_params
                     )
            [chr_region, html]
          end
        end
      end

      # @return [C3js::Data]
      def coverage_stats
        @samples.flat_map do |sample|
          sample
            .cram
            .picard_collect_wgs_metrics_collection
            .picard_collect_wgs_metrics.map do |e|
            h = COVERAGE_STATS_TYPES.keys.map.to_h do |type|
              [type, e.coverage_stats.send(type)]
            end
            h.merge(sample_name: sample.name,
                    chr_region: e.chr_region)
          end
        end.then { |a| C3js::Data.new(a) }
      end

      # @return [Hash{ ChrRegion => Hash{ Symbol => String } }]
      def coverage_stats_html
        coverage_stats_cols = COVERAGE_STATS_TYPES.map do |id, label|
          C3js::Column.new(id, label)
        end
        coverage_stats.then do |data|
          WGS_METRICS_REGIONS.map.to_h do |chr_region|
            coverage_stats_cols.map.to_h do |col|
              bindto = "coverage_stats_#{chr_region.id}_#{col.id}"
              html = data.select(chr_region: chr_region)
                       .bar_chart_html(
                         @sample_col,
                         col,
                         bindto: bindto,
                         **@default_chart_params
                       )
              [col, html]
            end.then do |htmls_of_chr_region|
              [chr_region, htmls_of_chr_region]
            end
          end
        end
      end

      # @param result_dir [Pathname]
      # @return           [Pathname]
      def plot_autosome_PAR_mean_coverage(result_dir)
        autosome_PAR_mean_coverages = @samples.map do |sample|
          sample.cram
                .picard_collect_wgs_metrics_collection
                .picard_collect_wgs_metrics
                .find do |wgs_metrics|
            wgs_metrics.chr_region.id == :'autosome-PAR'
          end.coverage_stats.mean
        end
        autosome_PAR_mean_coverages_tsv_path =
          result_dir / 'autosome-PAR_mean_coverages.tsv'
        tsv_header = 'autosome_PAR_mean_coverage'
        CSV.open(autosome_PAR_mean_coverages_tsv_path,
                 'w',
                 col_sep: "\t") do |csv|
          csv << [tsv_header]
          autosome_PAR_mean_coverages.each do |cov|
            csv << [cov]
          end
        end
        plot_path = autosome_PAR_mean_coverages_tsv_path.sub_ext('.hist.png')
        r_script = <<~R_SCRIPT
          library(ggplot2)
          library(readr)

          d <- as.data.frame(read_tsv("#{autosome_PAR_mean_coverages_tsv_path}"))
          g <- ggplot(d, aes(x = #{tsv_header}))
          g <- g + geom_histogram(position="identity", alpha=0.8, color="darkgreen")
          g <- g + theme_classic()
          g <- g + theme(text=element_text(size=20))
          g <- g + xlab("autosome-PAR mean coverage")
          g <- g + ylab("Number of subjects")
          ggsave(file="#{plot_path}", plot=g, height=5, width=8)
        R_SCRIPT
        r_submit(r_script, plot_path.sub_ext('.log'))
        plot_path
      end

      # @param cmd      [String]
      # @param log_path [Pathname]
      def r_submit(cmd, log_path)
        ret = nil
        File.open(log_path, 'w') do |f|
          Open3.popen3('R --slave --vanilla') do |i, o, e|
            i.puts cmd if cmd
            i.close
            o.each { |line| f.puts line }
            e.each { |line| f.puts line }
          end
        end
      end
    end
  end
end
