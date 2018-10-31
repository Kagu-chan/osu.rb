module Osu
  module Tool
    class Tool

      def self.run(args)
        Helper::Console.help_or_run(self, args)
      end

protected
      def self.help()
        warn 'No help definition given'
      end
    end
  end
end
