require 'sinatra'
require 'sinatra/cross_origin'
require 'sinatra/jsonp'
require 'dalli'
require 'json'
require 'twitter'

require_relative './lib/lyrics'
require_relative './lib/twitter_searcher'
require_relative './lib/tweet_cache'

# CORS related configs
enable :cross_origin
set :allow_methods, [:get, :options]
set :allow_credentials, false
set :max_age, "1728000"

set :twitter_searcher, TwitterSearcher.new

configure :development do
  # Fix thin logging
  $stdout.sync = true

  require 'sinatra/reloader'

  set :allow_origin, '*'

  set :tweet_cache, TweetCache.new(::Dalli::Client.new("localhost:11211", namespace: 'tweetflight'))
end

configure :production do
  set :allow_origin, 'http://tweetflight.wearebrightly.com'

  require 'newrelic_rpm'

  set :tweet_cache, TweetCache.new(
    ::Dalli::Client.new(ENV['MEMCACHIER_SERVERS'].split(','),
                        username: ENV['MEMCACHIER_USERNAME'],
                        password: ENV['MEMCACHIER_PASSWORD'],
                        namespace: 'tweetflight')
  )
end

helpers do
  def twitter_searcher
    settings.twitter_searcher
  end
  def tweet_cache
    settings.tweet_cache
  end
end

before do
  response.headers["Access-Control-Allow-Headers"] = "x-requested-with"
end

get '/tweets.json' do
  content_type :json
  results = Lyrics.all.collect {|lyric|
    {
      id: lyric.id,
      line: lyric.line,
      time: lyric.time,
      tweet: tweet_cache.get(lyric)
    }
  }
  jsonp results
end