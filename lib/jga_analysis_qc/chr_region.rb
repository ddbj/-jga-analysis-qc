# frozen_string_literal: true

require 'pathname'

module JgaAnalysisQC
  class ChrRegion
    # @return [Symbol]
    attr_reader :id

    # @return [String]
    attr_reader :desc

    # @param id   [String, Symbol]
    # @param desc [String]
    def initialize(id, desc = nil)
      @id = id.to_sym
      @desc = desc || @id.to_s
    end
  end
end
