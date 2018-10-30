require_relative('analyzer')

Osu::Tools.modules[:analyzer] = ->(args) { Osu::Tool::Analyzer.run(args) }
