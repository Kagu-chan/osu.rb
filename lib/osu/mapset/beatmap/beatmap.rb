module Osu
  module MapSet
    module BeatMap
      class BeatMap < LinesObject

        @@gametypeMap = {
          :'0' => Osu::MapSet::BeatMap::HitObject::Standard::HitObject,
          :'1' => Osu::MapSet::BeatMap::HitObject::Taiko::HitObject,
          :'2' => Osu::MapSet::BeatMap::HitObject::CatchTheBeat::HitObject,
          :'3' => Osu::MapSet::BeatMap::HitObject::Mania::HitObject
        }

        attr_reader :format,
                    :general,
                    :editor,
                    :metadata,
                    :difficulty,
                    :events,
                    :timingpoints,
                    :hitobjects,
                    :background,
                    :video,
                    :storyboard,
                    :mp3

        def initialize(file)
          @filename = file
          @sections = {}
          @format = nil
          @general = nil
          @editor = nil
          @metadata = nil
          @difficulty = nil
          @events = nil
          @timingpoints = nil
          @hitobjects = nil
          @background = nil
          @video = nil
          @storyboard = nil
          @mp3 = nil

          super []
        end

        def load()
          file = File.open(@filename, 'rb')
          content = file.read().gsub(/\r\n?/, "\n")
          file.close()

          convert_from_stream(content)

          set_format()
          set_section_as('General', KeyValuePair)
          
          HitObjects.type = @@gametypeMap[@sections[:General].mode.to_sym]

          set_section_as('Editor', KeyValuePair)
          set_section_as('Metadata', KeyValuePair)
          set_section_as('Difficulty', KeyValuePair)
          set_section_as('Events', Events)
          set_section_as('TimingPoints', TimingPoints)
          set_section_as('HitObjects', HitObjects)

          @general      = @sections[:General]
          @editor       = @sections[:Editor]
          @metadata     = @sections[:Metadata]
          @difficulty   = @sections[:Difficulty]
          @events       = @sections[:Events]
          @timingpoints = @sections[:TimingPoints]
          @hitobjects   = @sections[:HitObjects]

          @mp3        = @general.audiofilename
          @background = @events.background
          @video      = @events.video
          @storyboard = @events.storyboard

          @hitobjects.hitObjects.each { |hitObject|
            hitObject.set_row_by_circlesize(@difficulty.circlesize.to_i)
          }
        end

private
        def set_format()
          format_line = @lines[0]
          @format = format_line.gsub(/[\w]*/, '').to_i
        end

        def set_section_as(section, type)
          lines = read_from_to("[#{section}]", :empty)

          @sections[section.to_sym] = type.new(lines)
          @sections[section.to_sym].parse()
        end
      end
    end
  end
end
