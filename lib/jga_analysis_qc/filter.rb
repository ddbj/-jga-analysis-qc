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

    %w[min max].each do |extremum|
      const_set(
        "AUTOSOME_MEAN_COVERAGE_#{extremum.upcase}_KEY",
        "#{WGS_METRICS_AUTOSOME_REGION.id}_#{extremum}"
      )
      [
        ['X', WGS_METRICS_CHR_X_REGION],
        ['Y', WGS_METRICS_CHR_Y_REGION]
      ].each do |chr, region|
        %[male female].each do |sex|
          const_set(
            "CHR_#{chr}_NORMALIZED_MEAN_COVERAGE_#{sex}_#{extremum.upcase}_KEY",
            "#{region.id}_#{sex}_#{extremum}"
          )
        end
      end
    end

    class << self
      # @param result_dir [String]
      # @param param_path [String]
      def run(result_dir, param_path)
        result_dir = Pathname.new(result_dir)
        mean_coverage = load_mean_coverage(result_dir)
        param = YAML.load_file(param_path)
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

      def load_param(param_path)
      end

      # @param autosome_mean_coverage [Float]
      # @param param                  [Hash{ Symbol => Float }]
      # @return                       [Symbol] :PASS or :FAIL
      def filter_by_coverage(autosome_mean_coverage, param)
        prefix = "#{WGS_METRICS_AUTOSOME_REGION.id}_mean_coverage"
        if autosome_mean_coverage < param[:"#{prefix}_min"]
          :FAIL
        elsif param[:"#{prefix}_max"] < autosome_mean_coverage
          :FAIL
        else
          :PASS
        end
      end

      # @param chrX_normalized_mean_coverage [Float]
      # @param chrY_normalized_mean_coverage [Float]
      # @param param                         [Hash{ Symbol => Float }]
      # @return                              [Symbol] :PASS or :FAIL
      def estimate_sex(chrX_normalized_mean_coverage, chrY_normalized_mean_coverage, param)

      end
    end
  end
end
