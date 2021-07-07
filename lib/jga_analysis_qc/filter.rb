# frozen_string_literal: true

require 'pathname'
require 'yaml'
require 'csv'
require 'thor'

require_relative 'settings'
require_relative 'chr_region'

module JgaAnalysisQC
  module Filter
    include Thor::Shell

    FILTER_TABLE_FILENAME = 'qc.tsv'

    MIN_KEY = 'min'
    MAX_KEY = 'max'
    AUTOSOME_MEAN_COVERAGE_KEY = 'autosome_PAR_mean_coverage'
    MALE_KEY = 'male'
    FEMALE_KEY = 'female'
    CHR_X_NORMALIZED_MEAN_COVERAGE_KEY = 'chrX_nonPAR_normalized_mean_coverage'
    CHR_Y_NORMALIZED_MEAN_COVERAGE_KEY = 'chrY_nonPAR_normalized_mean_coverage'

    class << self
      # @param result_dir [String]
      # @param param_path [String]
      def run(result_dir, param_path)
        result_dir = Pathname.new(result_dir)
        mean_coverage = load_mean_coverage(result_dir)
        param = load_param(param_path)
        qc_path = result_dir / FILTER_TABLE_FILENAME
        CSV.open(qc_path, 'w', col_sep: "\t") do |tsv|
          tsv << %w[sample_id coverage_filter estimated_sex]
          table.each do |row|
            tsv << [
              row[:id],
              filter_by_coverage(row[AUTOSOME_MEAN_COVERAGE_KEY], param),
              estimate_sex(
                row[CHR_X_NORMALIZED_MEAN_COVERAGE_KEY],
                row[CHR_Y_NORMALIZED_MEAN_COVERAGE_KEY],
                param
              )
            ]
          end
        end
        say_status 'create', qc_path, :green
      end

      private

      # @param result_dir [Pathname]
      # @return           [CSV::Table]
      def load_mean_coverage(result_dir)
        table_path = result_dir / MEAN_COVERAGE_TABLE_FILENAME
        unless table_path.exist?
          say_status 'error', "cannot find #{table_path}", :red
          exit 1
        end
        CSV.table(table_path, col_sep: "\t")
      end

      # @param param_path [Pathname]
      # @return           [Hash]
      def load_param(param_path)
        unless param_path.exist?
          say_status 'error', "cannot find #{param_path}", :red
          exit 1
        end
        YAML.load_file(param_path)
      end

      # @param autosome_mean_coverage [Float]
      # @param param                  [Hash]
      # @return                       [Symbol] :PASS or :FAIL
      def filter_by_coverage(autosome_mean_coverage, param)
        h = param[AUTOSOME_MEAN_COVERAGE_KEY]
        if autosome_mean_coverage < h[MIN_KEY]
          :FAIL
        elsif h[MAX_KEY] < autosome_mean_coverage
          :FAIL
        else
          :PASS
        end
      end

      # @param chrX_normalized_mean_coverage [Float]
      # @param chrY_normalized_mean_coverage [Float]
      # @param param                         [Hash]
      # @return                              [Symbol] :MALE, :FEMALE, :OTHER
      def estimate_sex(chrX_normalized_mean_coverage, chrY_normalized_mean_coverage, param)
        if within_rectangle?(chrX_normalized_mean_coverage, chrY_normalized_mean_coverage, param[MALE_KEY])
          :MALE
        elsif within_rectangle?(chrX_normalized_mean_coverage, chrY_normalized_mean_coverage, param[FEMALE_KEY])
          :FEMALE
        else
          :OTHER
        end
      end

      # @param chrX_normalized_mean_coverage [Float]
      # @param chrY_normalized_mean_coverage [Float]
      # @param param_sex                     [Hash]
      # @return                              [Boolean]
      def within_rectangle?(chrX_normalized_mean_coverage, chrY_normalized_mean_coverage, param_sex)
        within_range?(chrX_normalized_mean_coverage, param_sex[CHR_X_NORMALIZED_MEAN_COVERAGE_KEY]) &&
          within_range?(chrY_normalized_mean_coverage, param_sex[CHR_Y_NORMALIZED_MEAN_COVERAGE_KEY])
      end

      # @param value         [Float]
      # @param param_max_min [Hash]
      # @return              [Boolean]
      def within_range?(value, param_max_min)
        param_max_min[MIN_KEY] <= value && value <= param_max_min[MAX_KEY]
      end
    end
  end
end
