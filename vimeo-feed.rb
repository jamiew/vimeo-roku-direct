require 'vimeo_me2'

class VimeoFeed

  def initialize
    videos = []
    next_page = '/me/videos'
    while true
      raw = fetch_results(next_page)
      break if raw.nil? || raw['data'].nil?
      videos += parse_videos(raw)
      next_page = raw['paging']['next']
    end

    puts "Found #{videos.length} videos total"
    names = videos.map{|v| v['name'] }
    pp names
    names
    # TODO now make the feed or whatever
  end

protected

  def fetch_results(endpoint)
    token = ENV['VIMEO_ACCESS_TOKEN']
    raise "No VIMEO_ACCESS_TOKEN defined" if token.nil? || token.empty?
    puts "Fetching #{endpoint} ..."
    VimeoMe2::Video.new(token, endpoint).video
  end

  def parse_videos(raw)

    # pp raw
    data = raw['data']
    return if data.nil?
    puts "Found #{data.length} videos"
    # TODO pagination
    data
  end

end


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
