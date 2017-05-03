require 'vimeo'
require 'pp'

username = "jamiew"

vids = Vimeo::Simple::User.videos("jamiew")

pp vids

