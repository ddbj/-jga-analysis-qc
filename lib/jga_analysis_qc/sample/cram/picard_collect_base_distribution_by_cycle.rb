# frozen_string_literal: true

require 'pathname'

module VCReport
  module Report
    class Sample
      class Cram
        class PicardCollectBaseDistributionByCycle
          # @return [Pathname]
          attr_reader :chart_png_path

          # @param chart_png_path [Pathname]
          def initialize(chart_png_path)
            @chart_png_path = chart_png_path
          end
        end
      end
    end
  end
end
