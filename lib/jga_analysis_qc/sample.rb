# frozen_string_literal: true

require 'fileutils'
require 'pathname'

require_relative 'settings'
require_relative 'sample/vcf_collection'
require_relative 'sample/cram'
require_relative 'report/render'

module VCReport
  class Sample
    # @return [String] sample name
    attr_reader :name

    # @return [Time, nil] workflow end time
    attr_reader :end_time

    # @return [VcfCollection]
    attr_reader :vcf_collection

    # @return [Cram, nil]
    attr_reader :cram

    # @param name           [String]
    # @param end_time       [Time, nil]
    # @param vcf_collection [VcfCollection]
    # @param cram           [Cram, nil]
    def initialize(name, end_time = nil, vcf_collection = nil, cram = nil)
      @name = name
      @end_time = end_time
      @vcf_collection = vcf_collection
      @cram = cram
    end
  end
end
