module Osu
  module MapSet
    module BeatMap
      module HitObject
        class Sample

          attr_reader :sampleType, :a, :b, :c, :d, :e, :f

          def initialize(sampleType, sampleConfig)
            @sampleType = sampleType
            @a, @b, @c, @d, @e = sampleConfig
          end
        end
      end
    end
  end
end
