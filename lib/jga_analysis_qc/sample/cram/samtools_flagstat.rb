# frozen_string_literal: true

require 'pathname'

require_relative '../../report/table'

module VCReport
  module Report
    class Sample
      class Cram
        class SamtoolsFlagstat
          class NumReads
            # @return [Integer]
            attr_reader :passed

            # @return [Integer]
            attr_reader :failed

            # @param passed [Integer]
            # @param failed [Integer]
            def initialize(passed, failed)
              @passed = passed
              @failed = failed
            end
          end

          FIELDS = {
            total: 'in total',
            secondary: 'secondary',
            supplementary: 'supplementary',
            duplicates: 'duplicates',
            mapped: 'mapped',
            paired_in_sequencing: 'paired in sequencing',
            read1: 'read1',
            read2: 'read2',
            properly_paired: 'properly paired',
            itself_and_mate_mapped: 'with itself and mate mapped',
            singletons: 'singletons',
            mate_mapped_to_different_chr:
              'with mate mapped to a different chr',
            mate_mapped_to_different_chr_mq_ge5:
              'with mate mapped to a different chr (mapQ>=5)'
          }.freeze

          # @return [Pathname]
          attr_reader :path

          # @return [NumReads]
          attr_reader(*FIELDS.keys)

          # @param path         [Pathname]
          # @param params       [Hash{ Symbol => Object }]
          def initialize(path, **params)
            @path = path
            params.each { |k, v| instance_variable_set("@#{k}", v) }
          end

          # @return [Table]
          def path_table
            Table.file_table(@path, 'metrics file')
          end

          # @return [Table]
          def num_reads_table
            header = ['description', '# of passed reads', '# of failed reads']
            rows = FIELDS.map do |attr, desc|
              num_reads = send(attr)
              [desc, num_reads.passed, num_reads.failed]
            end
            type = %i[string integer integer]
            Table.new(header, rows, type)
          end

          class << self
            # @param samtools_flagstat_path [Pathname]
            # @return                       [SamtoolsFlagstat, nil]
            def parse(samtools_flagstat_path)
              return nil unless samtools_flagstat_path

              params = {}
              File.foreach(samtools_flagstat_path, chomp: true) do |line|
                is_valid_line = false
                SamtoolsFlagstat::FIELDS.each do |attr, trailing|
                  num_alignments = extract_pass_and_fail(line, trailing)
                  next unless num_alignments

                  params[attr] = num_alignments
                  is_valid_line = true
                end
                unless is_valid_line
                  warn "Invalid line: #{line}"
                  exit 1
                end
              end
              SamtoolsFlagstat.new(samtools_flagstat_path, **params)
            end
          end
        end
      end
    end
  end
end
