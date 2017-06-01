require 'sinatra/base'
require 'json'

class App < Sinatra::Base

  get '/' do
    content_type :json
    # VimeoFeed.new
    File.read('example-feed.json')
  end

end
