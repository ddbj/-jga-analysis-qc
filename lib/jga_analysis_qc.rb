# frozen_string_literal: true

require 'thor'

require_relative 'jga_analysis_qc/version'
require_relative 'jga_analysis_qc/report'

module JgaAnalysisQC
  module CLI
    class Main < Thor
      def self.exit_on_failure?
        true
      end

      desc 'report [DIR] [SAMPLE LIST]', 'Produce a report on per-sample workflow results'
      def report(dir, sample_list_path)
        Report.run(sample_list_path, region_list_path)
      end
    end
  end
end
