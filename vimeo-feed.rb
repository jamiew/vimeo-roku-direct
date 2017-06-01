require 'vimeo_me2'
require 'redis'

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
      'lastUpdated' => Time.now, # FIXME: 2016-10-06T18:12:32.125Z
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

  def build_video(video)
    thumbnail = video['pictures'].select{|v| v['width'] == 960 }
    video_file = video['files'].select{|v| v['type'] == 'video/mp4'}[0]
    # TODO make all files available and let Roku figure it out

    {
      "id": video_id_for(video),
      "title": video['name'],
      "shortDescription": video['description'],
      "thumbnail": thumbnail,
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
      "releaseDate": video['release_time'], # FIXME does this have to be a date?
      "content": {
        "dateAdded": video['created_time'],  # FIXME is the time formatted correctly?
        "captions": [],
        "duration": video['duration'],
        "adBreaks": [
          "00:00:00",
          # "00:00:53"
        ],
        "videos": [
          # TODO load all the filetypes, both Mp4 and HLS (right?)
          {
            # "url": "http://roku.cpl.delvenetworks.com/media/59021fabe3b645968e382ac726cd6c7b/decbe34b64ea4ca281dc09997d0f23fd/aac0cfc54ae74fdfbb3ba9a2ef4c7080/117_segment_2_twitch__nw_060515.mp4",
            "url": video_file['link_secure'],
            "quality": "HD",
            "videoType": "MP4"
          }
        ]
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
        "name": "art",
        "itemIds": [
          id_groups[0]
        ]
      },
      {
        "name": "technology",
        "itemIds": [
          id_groups[1]
        ]
      },
      {
        "name": "open-source",
        "itemIds": [
          id_groups[3]
        ]
      }
    ]
  end

  def build_categories(videos)
    [
      {
        "name": "Art",
        "playlistName": "art",
        "order": "manual"
      },
      {
        "name": "Technology",
        "playlistName": "technology",
        "order": "manual"
      },
      {
        "name": "Open-Source",
        "playlistName": "open-source",
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
    # pp raw
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
