# frozen_string_literal: true

require 'pathname'
require_relative '../../report/table'
require_relative '../../report/sample/cram/picard_collect_wgs_metrics'

module VCReport
  module Report
    class Sample
      class Cram
        class PicardCollectWgsMetricsCollection
          # @return [Array<PicardCollectWgsMetrics>]
          attr_reader :picard_collect_wgs_metrics

          # @param picard_collect_wgs_metrics [Array<PicardCollectWgsMetrics>]
          def initialize(picard_collect_wgs_metrics)
            @picard_collect_wgs_metrics = picard_collect_wgs_metrics
          end

          # @return [Boolean]
          def empty?
            @picard_collect_wgs_metrics.empty?
          end
        end
      end
    end
  end
end
