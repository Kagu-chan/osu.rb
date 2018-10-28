module Osu
  module BeatMap
    class HitObject
        
      attr_reader :ln, :row, :position, :end_position, :hitsound
      
      def initialize(line, difficulty)
          data = line.split(",")
          
          @row = data[0].to_i / (512 / difficulty[:"CircleSize"].to_i) + 1
          @position = data[2]
          
          @ln = data[5].split(":").size == 6
      end
      
    end
  end
end
