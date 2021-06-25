# frozen_string_literal: true

require 'yaml'
require 'pathname'

require_relative 'chr_region'
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
      def run(result_dir, sample_list_path)
        result_dir = Pathname.new(result_dir)
        Render.copy_file(GITHUB_MARKDOWN_CSS_PATH, result_dir)
        samples = load_sample_list(sample_list_path).map do |sample_name|
          Sample.parse(result_dir, sample_name).tap(&:render)
        end
        progress_html_paths = Progress.new(result_dir, samples).render
        dashboard_html_path = Dashboard.new(result_dir, samples).render
        Render.run(INDEX_PREFIX, result_dir, binding)
      end

      private

      # @param sample_list_path [String]
      # @return                 [Array<String>]
      def load_sample_list(sample_list_path)
        YAML.load_file(sample_list_path)
      end
    end
  end
end
