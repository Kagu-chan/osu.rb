module Osu
  module MapSet
    module BeatMap
      class TimingPoints < Section

        attr_reader :timingSections

        def initialize(lines)
          super

          @timingSections = []
        end

        def parse()
          @lines.each_with_index { |line, index|
            next_index = index + 1
            next_line = @lines.size >= next_index ? @lines[next_index] : '0'

            @timingSections << TimingSection.new(line, next_line)
          }
        end
      end
    end
  end
end
