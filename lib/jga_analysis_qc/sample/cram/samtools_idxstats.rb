# frozen_string_literal: true

require 'pathname'

require_relative '../../report/table'

module VCReport
  module Report
    class Sample
      class Cram
        class SamtoolsIdxstats
          TABLE_COLUMNS = [
            ['chr. region', :name, :string],
            ['# of mapped reads',   :num_mapped,   :integer],
            ['# of unmapped reads', :num_unmapped, :integer]
          ].freeze

          class Chromosome
            # @return [String] "chr..." is supposed
            attr_reader :name

            # @return [Integer]
            attr_reader :length

            # @return [Integer] # of mapped reads
            attr_reader :num_mapped

            # @return [Integer] # of unmapped reads
            attr_reader :num_unmapped

            def initialize(name, length, num_mapped, num_unmapped)
              @name = name
              @length = length
              @num_mapped = num_mapped
              @num_unmapped = num_unmapped
            end
          end

          # @return [Pathname]
          attr_reader :path

          # @return [Chromosome]
          attr_reader :chromosomes

          # @param chromosomes [Array<Chromosome>]
          def initialize(path, chromosomes)
            @path = path
            @chromosomes = chromosomes
          end

          # @return [Table]
          def path_table
            Table.file_table(@path, 'metrics file')
          end

          # @return [Table]
          def num_reads_table
            header, messages, type = TABLE_COLUMNS.transpose
            rows = @chromosomes.map do |chromosome|
              messages.map do |message|
                chromosome.send(message)
              end
            end
            Table.new(header, rows, type)
          end

          class << self
            # @param samtools_idxstats_path [Pathname]
            # @return                       [SamtoolsIdxstats, nil]
            def parse(samtools_idxstats_path)
              return nil unless samtools_idxstats_path

              rows = CSV.read(samtools_idxstats_path, col_sep: "\t")
              all_chrs = rows.map.to_h do |name, *args|
                args.map!(&:to_i)
                [name, SamtoolsIdxstats::Chromosome.new(name, *args)]
              end
              target_names = TARGET_CHROMOSOMES.map { |x| "chr#{x}" }
              target_chrs = all_chrs.values_at(*target_names)
              SamtoolsIdxstats.new(samtools_idxstats_path, target_chrs)
            end
          end
        end
      end
    end
  end
end
