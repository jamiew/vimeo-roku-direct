require 'rubygems'
require 'bundler/setup'
require 'dotenv'
Dotenv.load

require './vimeo-feed'
require 'sinatra/base'
require 'json'
require 'benchmark'

class App < Sinatra::Base

  get '/' do
    content_type :json
    feed = VimeoFeed.new
    output = feed.data

    # if data is AWOL, run inline to the request (and cache)
    if output.nil? || output.empty?
      puts "Empty data feed, updating now..."
      time = Benchmark.realtime {
        output = feed.run_and_save
      }
      puts "Took #{time}s"
    end
    output
  end

  get '/update' do
    VimeoFeed.new.run_and_save
  end

  get '/example.json' do
    content_type :json
    File.read('feeds/example.json')
  end

end
