# frozen_string_literal: true

require 'pathname'

module JgaAnalysisQC
  class Sample
    class FastqcReport
      # @return [String]
      attr_reader :read_id

      # @return [Pathname]
      attr_reader :html_path

      def initialize(read_id, html_path)
        @read_id = read_id.to_s
        @html_path = Pathname.new(html_path)
      end
    end
  end
end
