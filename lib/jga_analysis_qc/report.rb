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
          sample = read_sample(result_dir, sample_name)
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
      # @return            [Sample]
      def read_sample(result_dir, sample_name)
        sample_dir = result_dir / sample_name
        vcf_collection = read_vcf_collection(sample_dir, sample_name)
        cram = read_cram(sample_dir, sample_name)
        Sample.new(sample_name, nil, vcf_collection, cram)
      end

      # @param sample_dir  [Pathname]
      # @param sample_name [String]
      # @return            [VcfCollection]
      def read_vcf_collection(sample_dir, sample_name)
        vcfs = HAPLOTYPECALLER_REGIONS.filter_map do |chr_region|
          vcf_basename = "#{sample_name}.#{chr_region.id}.g.vcf.gz"
          vcf_path = sample_dir / vcf_basename
          next unless vcf_path.exist?

          bcftools_stats_path = sample_dir / "#{vcf_basename}.bcftools_stats"
          bcftools_stats = BcftoolsStats.parse(chr_region, bcftools_stats_path)
          Vcf.new(vcf_path, chr_region, bcftools_stats)
        end
        VcfCollection.new(vcfs)
      end

      # @param sample_dir  [Pathname]
      # @param sample_name [String]
      # @return            [Cram, nil]
      def read_cram(sample_dir, sample_name)
        cram_basename = "#{sample_name}.cram"
        cram_path = sample_dir / cram_basename
        return nil unless cram_path.exist?

        Cram.new(
          cram_path,
          SamtoolsIdxtats.parse(sample_dir / "#{cram_basename}.idxstats"),
          SamtoolsFlagstat.parse(sample_dir / "#{cram_basename}.flagstat"),
          read_picard_collect_wgs_metrics_collection(sample_dir, cram_basename),
          read_picard_collect_base_distribution_per_cycle(sample_dir, cram_basename)
        )
      end

      # @param sample_dir    [Pathname]
      # @param cram_basename [String]
      # @return              [PicardCollectWgsMetricsCollection]
      def read_picard_collect_wgs_metrics_collection(sample_dir, cram_basename)
        picard_collect_wgs_metrics = WGS_METRICS_REGIONS.flat_map do |chr_region|
          picard_collect_wgs_metrics_path =
            sample_dir / "#{cram_basename}.#{chr_region.id}.wgs_metrics"
          PicardCollectWgsMetrics.parse(picard_collect_wgs_metrics_path)
        end
        PicardCollectWgsMetricsCollection.new(picard_collect_wgs_metrics)
      end

      # @param sample_dir    [Pathname]
      # @param cram_basename [String]
      # @return              [PicardCollectBaseDistributionByCycle, nil]
      def read_picard_collect_base_distribution_per_cycle(sample_dir, cram_basename)
        chart_png_path =
          sample_dir / "#{cram_basename}.collect_base_dist_by_cycle.chart.png"
        return nil unless chart_png_path.exist?

        PicardCollectBaseDistributionByCycle.new(chart_png_path)
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
