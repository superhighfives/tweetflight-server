![Tweetflight](https://user-images.githubusercontent.com/449385/218269502-e5b90d70-baf8-4328-b67d-c1844a9ef260.svg)

# Tweetflight (server)

A memcache-enabled server to fetch and store tweets based on a collection of search terms.

☝️ Tweetflight includes a separate client that handles the front end:
https://github.com/superhighfives/tweetflight-archive

## Requirements

* Ruby 1.9
* Bundler (`gem install bundler`)
* Memcached (`brew install memcached`)
* A Twitter application (https://dev.twitter.com/)

## Setup

Copy the sample foreman enviroment, customising the Twitter keys to catch the
twitter app you created.

    bundle
    cp sample.env .env

## Running

    memcached &
    bundle exec foreman start

## Refreshing Tweets

Locally:

    bundle exec foreman run ruby scripts/fetch.rb

or via the Heroku Scheduler add-on:

    ruby scripts/fetch.rb

## Deploying

You also need to make sure the correct Twitter app env values are set:

    heroku config:add TWITTER_CONSUMER_KEY blahblahblah
    etc

## License

This code (not including the lyrics) is licensed under a [Creative Commons Attribution License](http://creativecommons.org/licenses/by/3.0/): you may use it, but you must give attribution.
