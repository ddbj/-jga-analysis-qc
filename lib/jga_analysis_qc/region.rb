# frozen_string_literal: true

module JgaAnalysisQc
  RegionId = Symbol

  class Region
    # @return [Symbol]
    attr_reader :id

    # @return [String]
    attr_reader :label

    # @param id    [String, Symbol]
    # @param label [String]
    def initialize(id, label)
      @id = id.to_sym
      @label = label
    end
  end
end
