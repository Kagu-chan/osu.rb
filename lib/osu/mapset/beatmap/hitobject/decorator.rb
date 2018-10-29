module Osu
  module MapSet
    module BeatMap
      module HitObject
        class Decorator

          def self.decorate(hitobject, beatmap)
            hitobject.update_type()
            hitobject.update_samples()
          end
        end
      end
    end
  end
end
