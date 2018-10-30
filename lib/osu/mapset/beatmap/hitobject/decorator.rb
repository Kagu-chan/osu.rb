module Osu
  module MapSet
    module BeatMap
      module HitObject
        class Decorator

          def self.decorate(hitObject, beatmap)
            hitObject.update_type()
            hitObject.update_samples()
            hitObject.update_noteEnd()
            hitObject.apply_timing_sections(beatmap.timingpoints)
          end
        end
      end
    end
  end
end
