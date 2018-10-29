module Osu
  module MapSet
    module BeatMap
      module HitObject
        class Sample

          attr_reader :sampleType, :sampleSet, :sampleAddition, :sampleSetID, :volume, :fileName

          def initialize(sampleType, sampleConfig)
            @sampleType = sampleType
            # sampleType
            # 0 = nichts
            # 2 = whistle
            # 4 = finnish
            # 8 = clap
            # bit operator => 2 | 4 = 6 => whistle finnish

            # sampleSet
            # 0 = from timing section
            # 1 = normal
            # 2 = soft
            # 3 = drum

            # sampleAddition => seems to overwrite sampleSet
            # 0 = nothing
            # 1 = normal
            # 2 = soft
            # 3 = drum

            # sampleSetID => overwrite the sample set from timing point
            # 0 = from timing section
            # >= 1 = use this one
            @sampleSet, @sampleAddition, @sampleSetID, @volume, @fileName = sampleConfig
          end
        end
      end
    end
  end
end
