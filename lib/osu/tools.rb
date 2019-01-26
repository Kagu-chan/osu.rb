module Osu
  class Tools

    @@modules = {
      :help => ->(args) { self.help(args) },
      :list_tools => ->(args) { self.list_tools(args) }
    }

    @@retry = false

    def self.run()
      args = ARGV
      tool = args.shift()

      unless tool
        self.help(nil)
        Kernel.exit
      end
      tool_name = tool.to_sym

      begin
        self.run_tool(tool_name, args)
      rescue Exception => err
        self.help(nil)

        throw err
      end
    end

    def self.modules()
      @@modules
    end

private
    def self.help(args)
      puts <<TXT
Usage: ruby osr.rb TOOL [options] [arguments]
  tools are registered by placing them into `lib/osu/tool/`

  A tool consists of a `main.rb` and may contain additional files

  options and arguments depends on the tool - if you want to know more,
  type `ruby osr.rb TOOL -help`

available system tools:
  - list_tools
    list available tools

  - help
    This help

TXT
    end

    def self.list_tools(args)
      dir = File.expand_path('tool', File.dirname(__FILE__))
      tools = (Dir.entries(dir) - ['.', '..']).select() { |file| !file.end_with?('.rb') }
      tools_formatted = tools.join("\n  - ")
      puts <<TXT
Available system tools
  - list_tools
    list available tools

  - help
    general help

Available additional tools
  - #{tools_formatted}

TXT
    end

    def self.run_tool(tool_name, args)
      tool = @@modules[tool_name]

      if !tool then
        if (@@retry) then
          raise LoadError, "tool `#{tool_name}` could not be loaded"
        else
          self.try_load_tool(tool_name, args)
        end
      else
        @@retry = false
        tool.call(args)
      end
    end

    def self.try_load_tool(tool, args)
      file = File.expand_path("tool/#{tool}/main.rb", File.dirname(__FILE__))

      if FileTest.exist?(file) then
        require_relative(file)

        @@retry = true
        self.run_tool(tool, args)
      else
        raise NotImplementedError, "tool `#{tool}` does not exist"
      end
    end
  end
end
