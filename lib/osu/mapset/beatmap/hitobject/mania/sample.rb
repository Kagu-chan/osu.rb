module Osu
  module MapSet
    module BeatMap
      module HitObject
        module Mania
          class Sample < Osu::MapSet::BeatMap::HitObject::Sample

            def get_sample_file_names()
              result = super
              if (!result) then
                sampleType = @sampleType
                sampleSet = @sampleSet
                sampleSetID = @sampleSetID
                timingSection = @timingSection

                sampleSet = timingSection.sampletype if !sampleSet
                sampleSet = @sampleAddition if @sampleAddition

                sampleSetID = timingSection.sampleset if sampleSetID == 0

                return get_file_names_by_config(sampleSet, sampleSetID, sampleType)
              end

              return result
            end

protected
            def get_file_names_by_config(sampleSet, sampleSetID, sampleType)
              soundMapping = [
                'normal',
                'whistle',
                'finish',
                'clap'
              ]
              set = sampleSet.to_s.downcase

              sounds = []
              if sampleType == 0 then
                sounds = [0]
              else
                sounds << 1 if sampleType & 2 == 2
                sounds << 2 if sampleType & 4 == 4
                sounds << 3 if sampleType & 8 == 8
              end

              sounds.map! { |s|
                sampleSetID > 0 ? "#{set}-hit#{soundMapping[s]}#{sampleSetID != 1 ? sampleSetID : ''}.wav" : ''
              }

              return sounds
            end
          end
        end
      end
    end
  end
end
