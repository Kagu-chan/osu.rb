module Osu
  module MapSet
    module BeatMap
      module HitObject
        class Sample

          attr_reader :sampleType, :sampleSet, :sampleAddition, :sampleSetID, :volume, :fileName

          def initialize(sampleConfig)
            ##
            # Sample type number
            #
            # The sample applied to the hit object. bit operations used to combine multiple, e.g 6 respondes to 2 + 4
            #
            # 0 = nothing
            # 2 = whistle
            # 4 = finnish
            # 8 = clap
            @sampleType = sampleConfig[:sampleType]

            ##
            # Overwrite the currently applied timing section sample set for the current tick
            #
            # 0 = use timing section
            # 1 = normal sample set
            # 2 = soft sample set
            # 3 = drum sample set
            @sampleSet = sampleConfig[:sampleSet]

            ##
            # Add a additional sample set to the current tick
            #
            # Works only in conjunction with @sampleType
            #
            # NOTE: Bug in osu!mania - In osu!mania this actually disables the @sampleSet completely
            #       Unneccessary if it comes via per object configuration or timing section
            #
            # 0 = no additional sound
            # 1 = normal sample set
            # 2 = soft sample set
            # 3 = drum sample set
            @sampleAddition = sampleConfig[:sampleAddition]

            ##
            # Play a different sample set id then normally
            #
            # 0 correspondes to the current sample set per configuration
            # >= 1 overwrites it per object
            @sampleSetID = sampleConfig[:sampleSetID]

            ##
            # Overwrite the volume of the current tick
            #
            # 0 correspondes to the current sample volume per configuration
            @volume = sampleConfig[:volume]

            ##
            # Use a specific hitsound by file name
            #
            # If empty, the sample to play is determined by the configuration
            # If not, @sampleType, @sampleSet, @sampleAddition and @sampleSetID is ignored
            @fileName = sampleConfig[:fileName]
          end
        end
      end
    end
  end
end
