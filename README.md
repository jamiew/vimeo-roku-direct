Vimeo Roku Feed
===============

*Work In Progress, proceed at your own risk.* Pull requests welcome.

Instantly publish a Roku app powered by your Vimeo channel.

This app generates and serves a Roku Direct-compatible feed using data from the Vimeo API.

Note that this requires a [Vimeo PRO](https://vimeo.com/upgrade) or [Vimeo Business](https://vimeo.com/upgrade) account.

More info on Roku Direct Publisher here: https://blog.roku.com/developer/2016/10/19/publishing-platform/


Setup
-----

```
bundle install
```

* Copy `.env.sample` to `.env.`
* Get a Vimeo access token on https://developer.vimeo.com and put it in `.env`

Usage
-----

* Fetch your Vimeo videos: `bundle exec ruby vimeo-feed.rb`. This generates a Roku-compatible feed and saves it to disk.
* Run the web server: `bundle exec rackup config.ru` (or `foreman start`)

Then fetch and upate your feed on a regular basis.

TODO
----

* Make feed updates easier, or automated in a foreman worker process
* Heroku deployment instructions
* Tests tests tests tests

Contributors
------------

* Jamie Wilkinson ([@jamiew](http://github.com/jamiew))


License
-------

Released under an [MIT License](https://opensource.org/licenses/MIT)
