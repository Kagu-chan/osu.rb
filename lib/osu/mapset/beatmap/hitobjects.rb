module Osu
  module MapSet
    module BeatMap
      class HitObjects < Section

        @@type = nil

        attr_reader :hitObjects

        def initialize(lines)
          super

          @hitObjects = []
        end

        def parse()
          @lines.each { |line|
            @hitObjects << @@type.new(line)
          }
        end

        def self.type=(type)
          @@type = type
        end
        
        def get_used_files()
          files = @hitObjects.map { |hit| hit.get_used_files() }
          files
        end
      end
    end
  end
end
