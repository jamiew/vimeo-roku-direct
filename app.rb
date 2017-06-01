require 'sinatra/base'
require 'json'

class App < Sinatra::Base

  get '/' do
    content_type :json
    File.read('feeds/vimeo.json')
  end

  get '/example.json' do
    content_type :json
    File.read('feeds/example.json')
  end

end
