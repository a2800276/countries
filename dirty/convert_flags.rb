
Dir.glob("flags_wiki/*").each { |fn|
  puts fn
  puts "gm convert -geometry 16X11 #{fn} #{fn.gsub(/svg/, 'png').gsub(/flags_wiki/, "../flags")}"
  `gm convert -geometry 16X11 #{fn} #{fn.gsub(/svg/, 'png').gsub(/flags_wiki/, "../flags")}`
}
