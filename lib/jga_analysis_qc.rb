# frozen_string_literal: true

require 'thor'

require_relative 'jga_analysis_qc/version'
require_relative 'jga_analysis_qc/report'
require_relative 'jga_analysis_qc/filter'

module JgaAnalysisQC
  module CLI
    class Main < Thor
      def self.exit_on_failure?
        true
      end

      desc 'report [DIR] [SAMPLE LIST]', 'Produce a report on per-sample workflow results'
      method_option :show_path, :type => :boolean, :default => true
      def report(result_dir, sample_list_path)
        Report.run(result_dir, sample_list_path, show_path: options[:show_path])
      end

      desc 'filter [DIR] [PARAMETER]', 'Performs QC according to the given parameters'
      def filter(result_dir, param_path)
        Filter.run(result_dir, param_path)
      end
    end
  end
end
