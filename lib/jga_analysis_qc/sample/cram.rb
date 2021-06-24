# frozen_string_literal: true

require_relative '../report/table'
require_relative 'cram/samtools_idxstats'
require_relative 'cram/samtools_flagstat'
require_relative 'cram/picard_collect_wgs_metrics_collection'
require_relative 'cram/picard_collect_base_distribution_by_cycle'

module JgaAnalysisQC
  module Report
    class Sample
      class Cram
        # @return [SamtoolsIdxstats, nil]
        attr_reader :samtools_idxstats

        # @return [SamtoolsFlagstat, nil]
        attr_reader :samtools_flagstat

        # @return [PicardCollectWgsMetrics]
        attr_reader :picard_collect_wgs_metrics_collection

        # @return [PicardCollectBaseDistributionByCycle]
        attr_reader :picard_collect_base_distribution_by_cycle

        # @param cram_path                                 [Pathname]
        # @param samtools_idxstats                         [SamtoolsIdxstats, nil]
        # @param samtools_flagstat                         [SamtoolsFlagstat, nil]
        # @param picard_collect_wgs_metrics_collection     [PicardCollectWgsMetricsCollection]
        # @param picard_collect_base_distribution_by_cycle [PicardCollectBaseDistributionByCycle, nil]
        def initialize(
          cram_path,
          samtools_idxstats,
          samtools_flagstat,
          picard_collect_wgs_metrics_collection,
          picard_collect_base_distribution_by_cycle
        )
          @cram_path = cram_path
          @samtools_idxstats = samtools_idxstats
          @samtools_flagstat = samtools_flagstat
          @picard_collect_wgs_metrics_collection = picard_collect_wgs_metrics_collection
          @picard_collect_base_distribution_by_cycle = picard_collect_base_distribution_by_cycle
        end

        # @return [Table]
        def path_table
          Table.file_table(@cram_path, 'input file')
        end
      end
    end
  end
end
