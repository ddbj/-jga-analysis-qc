# frozen_string_literal: true

require 'pathname'

require_relative '../../chr_region'

module JgaAnalysisQC
  module Report
    class Sample
      class Vcf
        class BcftoolsStats
          # @return [Pathname]
          attr_reader :path

          # @return [ChrRegion]
          attr_reader :chr_region

          # @return [Integer]
          attr_reader :num_snps

          # @return [Integer]
          attr_reader :num_indels

          # @return [Float]
          attr_reader :ts_tv_ratio

          def initialize(path, chr_region, num_snps, num_indels, ts_tv_ratio)
            @path = path
            @chr_region = chr_region
            @num_snps = num_snps
            @num_indels = num_indels
            @ts_tv_ratio = ts_tv_ratio
          end

          class << self
            # @param chr_region          [chr_region]
            # @param bcftools_stats_path [Pathname]
            # @return                    [BcftoolsStats, nil]
            def parse(chr_region, bcftools_stats_path)
              return nil unless bcftools_stats_path.exist?

              lines = File.readlines(bcftools_stats_path, chomp: true)
              field = lines.filter_map do |line|
                line.split("\t") unless line =~ /^#/
              end.group_by(&:first)
              sn = field['SN'].map.to_h { |_, _, k, v| [k, v.to_i] }
              num_snps = sn['number of SNPs:']
              num_indels = sn['number of indels:']
              ts_tv_ratio = field['TSTV'].first[4].to_f
              BcftoolsStats.new(
                bcftools_stats_path,
                chr_region,
                num_snps,
                num_indels,
                ts_tv_ratio
              )
            end
          end
        end
      end
    end
  end
end
