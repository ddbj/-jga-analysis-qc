# frozen_string_literal: true

require 'yaml'
require 'pathname'

require_relative 'chr_region'
require_relative 'sample'
require_relative 'sample/vcf_collection'
require_relative 'sample/vcf'
require_relative 'sample/vcf/bcftools_stats'
require_relative 'sample/cram'
require_relative 'sample/cram/samtools_idxstats'
require_relative 'sample/cram/samtools_flagstat'
require_relative 'sample/cram/picard_collect_wgs_metrics_collection'
require_relative 'sample/cram/picard_collect_wgs_metrics'
require_relative 'sample/cram/picard_collect_base_distribution_by_cycle'
require_relative 'report/render'

module JgaAnalysisQC
  module Report
    HAPLOTYPECALLER_REGIONS = [
      ChrRegion.new('autosome-PAR',       'autosome-PAR'),
      ChrRegion.new('chrX-nonPAR-male',   'chrX-nonPAR (male)'),
      ChrRegion.new('chrX-nonPAR-female', 'chrX-nonPAR (female)'),
      ChrRegion.new('chrY-nonPAR',        'chrY-nonPAR')
    ].freeze
    WGS_METRICS_REGIONS = [
      WGS_METRICS_AUTOSOME_REGION,
      WGS_METRICS_CHR_X_REGION,
      WGS_METRICS_CHR_Y_REGION
    ].freeze
    TEMPLATE_NAME = 'report'

    class << self
      # @param result_dir       [String]
      # @param sample_list_path [String]
      def run(result_dir, sample_list_path)
        result_dir = Pathname.new(result_dir)
        sample_names = load_sample_list(sample_list_path)
        sample_names.each do |sample_name|
          sample = Sample.parse(result_dir, sample_name)
          render(result_dir, sample_name, sample)
        end
      end

      private

      # @param sample_list_path [String]
      # @return                 [Array<String>]
      def load_sample_list(sample_list_path)
        YAML.load_file(sample_list_path)
      end

      # @param result_dir  [Pathname]
      # @param sample_name [String]
      # @param sample      [Sample]
      # @return            [Pathname] HTML path
      def render(sample_dir, sample_name, sample)
        sample_dir = result_dir / sample_name
        Render.copy_file(GITHUB_MARKDOWN_CSS_PATH, result_dir)
        Render.run(
          TEMPLATE_NAME,
          sample_dir,
          binding,
          toc_nesting_level: SAMPLE_TOC_NESTING_LEVEL
        )
      end
    end
  end
end
