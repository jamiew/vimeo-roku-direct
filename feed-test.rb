require './vimeo-feed'
require 'pp'
require 'dotenv'

Dotenv.load

puts "Running..."

output = VimeoFeed.new.run

filename = 'feeds/vimeo.json'
File.open(filename, 'w+') {|f| f.write(output) }

puts "Wrote #{output.length} bytes to #{filename}"

