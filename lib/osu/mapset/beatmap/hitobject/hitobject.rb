module Osu
  module MapSet
    module BeatMap
      module HitObject
        class HitObject
          
          attr_reader :row,
                      :position,
                      :start,
                      :end,
                      :type,
                      :sample
          
          def initialize(line)
            @data = line.split(',')

            @position   = {
                          :x => @data[0].to_i,
                          :y => @data[1].to_i
                        }
            @start      = @data[2].to_i
            @end        = @start
            @type       = @data[3].to_sym
            @sampleType = @data[4].to_i
            @samples    = []
          end

          def update_type()
            warn('Method `update_type` should be overwritten')
          end

          def update_samples()
            warn('Method `update_samples` should be overwritten')
          end
        end
      end
    end
  end
end
