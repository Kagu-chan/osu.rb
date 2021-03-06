module Helper
  class LinesObject

    attr_reader :lines

    def initialize(lines)
      if lines.is_a? Array
        @lines = lines
      elsif lines.is_a? String
        convert_from_stream(lines)
      end
    end

    def self.read_from_file(file_name)
      file = File.open(file_name, 'rb')
      content = file.read().gsub(/\r\n?/, "\n")
      file.close()

      content
    end

protected
    def convert_from_stream(stream)
      @lines = []
      stream.each_line { |line| @lines << line }
    end

    def read_from_to(from, to=:end)
      lines = []
      
      _start = false
      @lines.each { |line|
        unless _start
          _start = line.start_with?(from.to_s)
        else
          if to == :end
            lines << line
          elsif to == :empty
            break if line == "\n"
            lines << line
          else
            break if line.start_with?(to.to_s)
            lines << line
          end
        end
      }
      
      return lines
    end
  end
end
