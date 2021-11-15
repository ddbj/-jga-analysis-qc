# frozen_string_literal: true

require 'yaml'
require 'pathname'

require_relative 'sample'
require_relative 'report/render'
require_relative 'report/progress'
require_relative 'report/dashboard'

module JgaAnalysisQC
  module Report
    INDEX_PREFIX = 'index'

    class << self
      # @param result_dir       [String]
      # @param sample_list_path [String]
      # @param show_path        [Boolean]
      # @param fastqc           [Boolean]
      def run(result_dir, sample_list_path, show_path: true, fastqc: false)
        result_dir = Pathname.new(result_dir).expand_path
        Render.copy_file(GITHUB_MARKDOWN_CSS_PATH, result_dir)
        samples = YAML.load_file(sample_list_path).map do |sample_name|
          Sample.parse(result_dir, sample_name, fastqc: fastqc)
                .tap { |e| e.render(show_path: show_path, fastqc: fastqc) }
        end
        progress_html_paths = Progress.new(result_dir, samples).render
        dashboard_html_path = Dashboard.new(result_dir, samples).render
        Render.run(INDEX_PREFIX, result_dir, binding)
      end
    end
  end
end
