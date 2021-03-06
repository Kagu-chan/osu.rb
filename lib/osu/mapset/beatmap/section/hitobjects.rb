module Osu
  module MapSet
    module BeatMap
      module Section
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
            # TODO: Does not return all files as it seems
            files = @hitObjects.map { |hit| hit.get_used_files() }
            files
          end
        end
      end
    end
  end
end
