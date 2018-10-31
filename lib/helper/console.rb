module Helper
  class Console

    @@parser = {
      :boolean => ->(value) { !["0", "f", "F", "false", "FALSE", "off", "OFF"].include?(value) }
    }

    def self.help_or_run(cls, args)
      if (args == ['-help']) then
        cls.help()
      else
        cls.new(*args).run()
      end
    end

    def self.parse_arguments(instance, defaults, args)
      loop {
        arg = args[0]
        if arg && arg.start_with?('-') then
          option, value = args.shift().sub(/^-/, '').split('=')
          option_name = option.to_sym

          if defaults[option_name] then
            if value != nil then
              parse = @@parser[defaults[option_name][0]]
              value = parse.call(value)
            else
              value = defaults[option_name][1]
            end
          else
            value = value || true
          end

          instance.instance_variable_set("@#{option}", value)
        else
          break
        end
      }
    end
  end
end
