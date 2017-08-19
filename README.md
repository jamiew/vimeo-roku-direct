Vimeo Roku Feed
===============

*Work In Progress, proceed at your own risk. Pull requests welcome.*

Instantly publish a Roku app powered by your Vimeo channel.

This app generates and serves a Roku Direct-compatible feed using data from the Vimeo API.

Note that this requires a [Vimeo PRO](https://vimeo.com/upgrade) or [Vimeo Business](https://vimeo.com/upgrade) account.

More info on Roku Direct Publisher here: https://blog.roku.com/developer/2016/10/19/publishing-platform/


Setup
-----

```
bundle install
```

* Get a Vimeo access token on https://developer.vimeo.com (make an app, then make an access token on the 'Authentication' tab)
* Copy `.env.sample` to `.env.`
* Put your VIMEO_ACCESS_TOKEN in `.env`

Usage
-----

* Fetch your Vimeo videos. This command generates a Roku-compatible feed and saves it to disk:

```
bundle exec ruby update-feed.rb
```

Or run it as a web server:

```
foreman start
```

If you don't have foreman installed:

```
bundle exec rackup config.ru
```

TODO
----

* Make feed updates easier, or automated in a foreman worker process
* Heroku deployment instruction
* Tests tests tests tests

Contributors
------------

* Jamie Wilkinson ([@jamiew](http://github.com/jamiew))


License
-------

Released under an [MIT License](https://opensource.org/licenses/MIT)
