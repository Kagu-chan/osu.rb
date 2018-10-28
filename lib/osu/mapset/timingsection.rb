module Osu
  module BeatMap
    class TimingSection
        
    attr_reader :offset, :until, :inherited, :sv, :bpm, :signature, :sampletype, :sampleset, :volume, :kiai
    
    def initialize(line, nextline)
      data = line.split(",")
      nextdata = nextline.split(",")
      
      @offset = data[0]
      @until = nextdata[0]
      
      @inherited = data[6] == "0"
      @value = data[1]
      
      @sv = 1.0
      @bpm = 0
      if @inherited
        @sv = -100.to_f / @value.to_f
      else
        @bpm = (60000 / @value.to_f).round(3)
      end
      
      @signature = data[2].to_i
      @sampletype = case data[3].to_i
        when 1 then :normal
        when 2 then :soft
        when 3 then :drum
      end
      @sampleset = data[4].to_i
      @volume = data[5].to_i
      
      @kiai = data[7] == "1"
    end
    
    def bpm=(value)
      raise("Numeric expected") unless value.is_a?(Numeric)
      @bpm = value
    end
    
    def until=(value)
      raise("Numeric expected") unless value.is_a?(Numeric)
      @until = value
    end
    
    end
  end
end
