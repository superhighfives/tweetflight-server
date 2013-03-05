# app.rb
require 'sinatra'
require 'sinatra/cross_origin'
require 'sinatra/jsonp'
require 'sinatra/dalli'
require 'json'
require 'twitter'
require 'ostruct'

# dev mode easy lols
configure :development do
  require 'sinatra/reloader'
end

# cross domain
configure :development do
  set :allow_origin, '*'
end
configure :production do
  set :allow_origin, 'http://tweetflight.wearebrightly.com'
end
set :allow_methods, [:get, :options]
set :allow_credentials, false
set :max_age, "1728000"

set :cache_default_expiry, 600

# dalli settings
configure :production do
  require 'newrelic_rpm'

  set :cache_client, ::Dalli::Client.new(ENV['MEMCACHIER_SERVERS'].split(','),
                                           :username => ENV['MEMCACHIER_USERNAME'],
                                           :password => ENV['MEMCACHIER_PASSWORD'])
end

configure do
  enable :cross_origin
end

before do
  response.headers["Access-Control-Allow-Headers"] = "x-requested-with"
end

def lyrics
  # 30ish of these
  [
    {id: 1, line: 'It was dark', time: 1},
    {id: 2, line: 'In the car park', time: 2},
    {id: 3, line: 'I heard a lark ascending', time: 3},
    {id: 4, line: 'And you laughed', time: 4},

    {id: 5, line: "And in my bones", time: 5},
    {id: 6, line: "I guess I've always known", time: 6},
    {id: 7, line: "There was a spark exploding", time: 7},
    {id: 8, line: "In the dry bark", time: 8},

    {id: 10, line: "you look sick", time: 9.5},
    {id: 12, line: "We are everything", time: 10.5},

    {id: 13, line: "And all my clothes", time: 14.5},
    {id: 14, line: "Well baby they were thrown", time: 15.5},
    {id: 15, line: "Into the sea", time: 16.5},
    {id: 16, line: "God I felt it when you left me", time: 17.5},

    {id: 17, line: "It hit me hard", time: 18.5},
    {id: 18, line: "In the car park", time: 19.5},
    {id: 19, line: "Cause I was always looking", time: 20.5},
    {id: 20, line: "For a spark", time: 21.5},

    {id: 21, line: "we can't lose", time: 23},
    {id: 23, line: "we never won", time: 24},

    {id: 25, line: "I'm going to make it anyway", time: 27},
    {id: 27, line: "I'm going to fake it baby", time: 29},

    {id: 29, line: "I feel it now", time: 32.5},
    {id: 30, line: "I feel it now", time: 33.5},
    {id: 31, line: "I feel it now", time: 34.5},
    {id: 32, line: "I feel it now", time: 35.5},
  ]
end

def tweet_for_lyric(lyric)
  # twitter search logic goes here
  tweet = do_twitter_search_for_lyric(lyric)
  if tweet
    {:text => tweet.text, :link => tweet.link, :username => tweet.username, :created_at => tweet.created_at}
  end
end

def is_tweet_ok(tweet)
  tweet.text !~ /RT/ && tweet.text !~ /@/ && tweet.text !~ /http/ && tweet.text !~ /&amp;/
end

def do_twitter_search_for_lyric(lyric)
  begin
    # search twitter
    chosen_tweet = Twitter.search("\"#{lyric[:line]}\"", :result_type => "recent").results.select{ |tweet| is_tweet_ok(tweet) }.sample
    if chosen_tweet
      OpenStruct.new(text: chosen_tweet.text, link: "http://twitter.com/#{chosen_tweet.from_user_id}/status/#{chosen_tweet.id}", username: chosen_tweet.from_user, created_at: chosen_tweet.created_at)
    end
  rescue
    # oh the lols. so many lols.
    # development? ? raise : nil
    nil
  end
end

get '/tweets.json' do
  content_type :json

  results = lyrics.map { |lyric|
    lyric[:tweet] = cache "lyrics_json_#{lyric[:id]}" do
      tweet_for_lyric(lyric) || ""
    end
    lyric
  }
  jsonp results
end

get '/cache/expire' do
  lyrics.map { |lyric|
    expire "lyrics_json_#{lyric[:id]}"
    lyric[:line]
  }.to_json
end

get '/cache/inspect' do
  send(:client).inspect
end
