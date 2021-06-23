# frozen_string_literal: true

require 'pathname'

module JgaAnalysisQC
  class ChrRegion
    # @return [Symbol]
    attr_reader :id

    # @return [String]
    attr_reader :label

    # @param id    [String, Symbol]
    # @param label [String]
    def initialize(id, label = nil)
      @id = id.to_sym
      @label = label || @id.to_s
    end
  end
end
