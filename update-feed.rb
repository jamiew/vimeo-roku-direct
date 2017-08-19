require 'rubygems'
require 'bundler/setup'
require 'dotenv'
Dotenv.load

require './vimeo-feed'

puts "Running..."

feed = VimeoFeed.new
output = feed.run_and_save

puts "Redis: wrote #{output.length} bytes to #{feed.send(:redis_connection_url)} redis_cache_key=#{feed.send(:redis_cache_key).inspect}"
