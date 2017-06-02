require 'vimeo_me2'
require 'redis'
require 'time'
require 'pp'

class VimeoFeed

  def initialize
    @videos = []
  end

  def run
    next_page = '/users/jamiew/videos'

    while true
      raw = fetch_results(next_page)
      break if raw.nil? || raw['data'].nil?
      @videos += parse_videos(raw)
      next_page = raw['paging']['next']
      break if next_page.nil? || next_page.empty?
    end

    puts "Found #{@videos.length} videos total"
    return build_output(@videos).to_json
  end

  def run_and_save
    output = self.run
    self.data = output
    output
  end

  def data
    redis.get(redis_cache_key)
  end

  def data=(raw)
    redis.set(redis_cache_key, raw)
  end


protected

  def redis_connection_url
    ENV['REDIS_URL'] || "redis://localhost:6379"
  end

  def redis
    @redis ||= Redis.new(url: redis_connection_url)
    # TODO raise error if no redis
  end

  def redis_cache_key
    "vimeo-feed.json"
  end


  def build_output(videos)
    {
      'providerName' => 'FAT Lab',
      'language' => 'en-US',
      'lastUpdated' => Time.now.iso8601,
      'shortFormVideos' => build_videos(videos),
      'playlists' => build_playlists(videos),
      'categories' => build_categories(videos),
    }
  end

  def build_videos(videos)
    videos.map{|v| build_video(v) }
  end

  def video_id_for(video)
    video['uri'].gsub('/videos/', '')
  end

  def format_video_file_for_roku(file)
    pp file

    if file['quality'] == 'hls'
      file['width'] = 1920 # just assume it's 1080p; FIXME grab highest rest MP4 and use that
    end

    quality = if file['width'] > 1920
      'UHD'
    elsif file['width'] == 1920
      'FHD'
    elsif file['quality'] == 'hd'
      'HD'
    else
      'SD'
    end

    video_type = if file['quality'] == 'hls'
      'HLS'
    else
      'MP4'
    end

    # totally guessing at bitrate for these files
    bitrate = if file['quality'] == 'hls'
      nil
    elsif file['width'] >= 1920
      7000
    elsif file['width'] >= 1280
      5000
    elsif file['width'] >= 640
      3000
    elsif file['width'] >= 480
      2000
    else
      1000 # ???
    end

    out = {
      'url' => file['link_secure'],
      'quality' => quality,
      'videoType' => video_type
    }
    out['bitrate'] = bitrate unless bitrate.nil?
    out
  end

  def build_video(video)
    thumbnail = video['pictures'].select{|v| v['width'] == 960 }[0]
    if thumbnail.nil? || thumbnail['link'].nil?
      puts "Could not find 960 width thumbnail for #{video.inspect}, falling back to whatever else is there"
      thumbnail = video['pictures'][0]
    end

    video_file = video['files'].select{|v| v['type'] == 'video/mp4'}[0]
    # TODO make all files available and let Roku figure it out

    {
      "id": video_id_for(video),
      "title": video['name'],
      "shortDescription": video['description'] || 'N/A',
      "thumbnail": thumbnail['link'],
      "genres": [
        # "gaming",
        # "technology"
      ],
      "tags": [
        # "gaming",
        # "broadcasts",
        # "live",
        # "twitch",
        # "technology"
      ],
      "releaseDate": Date.parse(video['release_time']).iso8601,
      "content": {
        "dateAdded": Time.parse(video['created_time']).iso8601,  # FIXME is the time formatted correctly?
        "captions": [],
        "duration": video['duration'],
        "adBreaks": [
          "00:00:00",
          # "00:00:53"
        ],
        "videos": video['files'].map{|v| format_video_file_for_roku(v) }
      }
    }
  end

  # FIXME all fake
  def build_playlists(videos)
    video_ids = videos.map{|v| video_id_for(v) }
    fake_playlists_count = 3
    id_groups = video_ids.each_slice(video_ids.length / fake_playlists_count).to_a

    [
      {
        "name": "first",
        "itemIds": [
          id_groups[0]
        ]
      },
      {
        "name": "second",
        "itemIds": [
          id_groups[1]
        ]
      },
      {
        "name": "third",
        "itemIds": [
          id_groups[3]
        ]
      }
    ]
  end

  def build_categories(videos)
    [
      {
        "name": "First",
        "playlistName": "first",
        "order": "manual"
      },
      {
        "name": "Second",
        "playlistName": "second",
        "order": "manual"
      },
      {
        "name": "third",
        "playlistName": "third",
        "order": "manual"
      }
    ]
  end

  def fetch_results(endpoint)
    token = ENV['VIMEO_ACCESS_TOKEN']
    raise "No VIMEO_ACCESS_TOKEN defined" if token.nil? || token.empty?
    puts "Fetching #{endpoint} ..."
    VimeoMe2::Video.new(token, endpoint).video
  end

  def parse_videos(raw)
    data = raw['data']
    return if data.nil?
    puts "Found #{data.length} videos on this page"
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
