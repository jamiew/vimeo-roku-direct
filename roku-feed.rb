require 'dotenv'
require 'vimeo_me2'
require 'pp'

Dotenv.load

def run
  videos = []
  next_page = '/me/videos'
  while true
    raw = fetch_results(next_page)
    break if raw.nil? || raw['data'].nil?
    videos += parse_videos(raw)
    next_page = raw['paging']['next']
  end

  puts "Found #{videos.length} videos total"
  pp videos.map{|v| v['name'] }
  # OK now make the feed or whatever
end

def fetch_results(endpoint)
  puts "Fetching #{endpoint} ..."
  VimeoMe2::Video.new(ENV['VIMEO_ACCESS_TOKEN'], endpoint).video
end

def parse_videos(raw)

  # pp raw
  data = raw['data']
  return if data.nil?
  puts "Found #{data.length} videos"
  # TODO pagination
  data
end


# OK go
run

=begin
[
"uri",
"name",
"description",
"link",
"duration",
"width",
"language",
"height",                                                                                                                        [0/9184]
"embed",
"created_time",
"modified_time",
"release_time",
"content_rating",
"license",
"privacy",
"pictures",
"tags",
"stats",
"metadata",
"user",
"files",
"download",
"app",
"status",
"resource_key",
"review_link",
"embed_presets"
]
=end
