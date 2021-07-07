# frozen_string_literal: true

require 'pathname'
require 'fileutils'

require_relative '../settings'
require_relative '../sample'
require_relative 'render'
require_relative 'paging'
require_relative 'table'

module JgaAnalysisQC
  module Report
    class Progress
     TEMPLATE_PREFIX = 'progress'

      # @return [Pathname]
      attr_reader :result_dir

      # @return [Array<Sample>]
      attr_reader :samples

      # @param result_dir [Pathname]
      # @param samples    [Array<Sample>]
      def initialize(result_dir, samples)
        @result_dir = result_dir
        @samples = samples
        max_pages = (MAX_SAMPLES.to_f / NUM_SAMPLES_PER_PAGE).ceil
        @num_digits = max_pages.digits.length
      end

      # @return [Array<Pathname>] HTML paths
      def render
        slices = @samples.each_slice(NUM_SAMPLES_PER_PAGE).to_a
        slices.map.with_index(1) do |slice, page_num|
          paging = Paging.new(page_num, slices.length, @num_digits)
          table = sample_slice_to_table(slice)
          Render.run(TEMPLATE_PREFIX, result_dir, binding, paging: paging)
        end
      end

      private

      # @param slice [Array<Sample>]
      # @return      [Table]
      def sample_slice_to_table(slice)
        header = ['sample_id']
        type = %i[string]
        link_rows = slice.map do |sample|
          sample_id = Render.markdown_link_text(sample.name, "#{sample.name}/report.html")
          [sample_id]
        end
        end_times = collect_end_time(slice).transpose
        header_end_time = end_times.shift
        header += header_end_time
        type += header_end_time.length.times('string')
        rows = html_rows.zip(end_times) { |*a| a.flatten }
        Table.new(header, rows, type)
      end

      # @param slice [Array<Sample>]
      # @return      [Array<Array>>]
      #              array whose each element is [header string, array of end-time string]
      def collect_end_time(slice)
        cols = []
        cols << ['CRAM', slice.map { |e| e.cram&.cram_path }]
        cols << ['idxstats', slice.map { |e| e.cram&.samtools_idxstats&.path }]
        cols << ['flagstat', slice.map { |e| e.cram&.samtools_flagstat&.path }]
        cols += WGS_METRICS_REGIONS.map do |chr_region|
          ["WGS metrics #{chr_region.desc}",
            slice.map { |e| find_wgs_metrics_of_region(e, chr_region)&.path }]
        end
        cols << [
          'base distribution by cicle',
          slice.map { |e| e.cram&.picard_collect_base_distribution_by_cycle&.path }
        ]
        HAPLOTYPECALLER_REGIONS.each do |chr_region|
          vcfs = slice.map { |e| find_vcf_of_region(e, chr_region)}
          cols << ["gVCF #{chr_region.desc}", vcfs.map { |e| e&.path }]
          cols << ["bcftools stats #{chr_region.desc}",
                   vcfs.map { |e| e&.bcftools_stats&.path}]
        end
        cols.map { |desc, path| [desc, end_time_string_from_path] }
      end

      # @param sample     [Sample]
      # @param chr_region [ChrRegion]
      # @return           [PicardCollectWgsMetrics, nil]
      def find_wgs_metrics_of_region(sample, chr_region)
        sample
          .cram
          .picard_collect_wgs_metrics_collection
          .picard_collect_wgs_metrics
          .find do |wgs_metrics|
          wgs_metrics.chr_region.id == chr_region.id
        end
      end

      # @param sample     [Sample]
      # @param chr_region [ChrRegion]
      # @return           [Vcf, nil]
      def find_vcf_of_region(sample, chr_region)
        sample.vcf_collection.vcfs.find do |vcf|
          vcf.chr_region.id == chr_region.id
        end
      end

      # @param path [Pathname]
      # @return     [String]
      def end_time_string_from_path(path)
        return '-' unless path && path.exist?

        path.mtime.strftime('%Y-%m-%d %H:%M:%S')
      end

      # @param prefix [String]
      # @param paging [Paging]
      # @return       [String]
      def navigation_markdown_text(prefix, paging)
        prev_text, next_text = %w[prev next].map do |nav|
          digits = paging.send(nav)&.digits
          if digits
            Render.markdown_link_text(nav, "#{prefix}#{digits}.html")
          else
            nav
          end
        end
        "\< #{prev_text} \| #{next_text} \>"
      end
    end
  end
end
