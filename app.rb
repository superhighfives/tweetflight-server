# app.rb
require 'sinatra'
require 'sinatra/cross_origin'
require 'sinatra/dalli'
require 'json'
require 'twitter'
require 'ostruct'

# dev mode easy lols
configure :development do
  require 'sinatra/reloader'
end

# cross domain
set :allow_origin, 'http://localhost:3501'
set :allow_methods, [:get, :post, :options]
set :allow_credentials, false

# dalli settings
set :cache_default_expiry, 3600
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
    {line: 'It was dark', time: 1},
    {line: 'In the car park', time: 2},
    {line: 'I heard a lark ascending', time: 3},
    {line: 'And you laughed', time: 4},

    {line: "And in my bones", time: 5},
    {line: "I guess I've always known", time: 6},
    {line: "There was a spark exploding", time: 7},
    {line: "In the dry bark", time: 8},

    {line: "Honey, you look sick", time: 10},
    {line: "Don't you know that this", time: 10.5},
    {line: "is everything?", time: 11},
    {line: "We are everything", time: 11.5},

    {line: "And all my clothes", time: 14.5},
    {line: "Well baby they were thrown", time: 15.5},
    {line: "Into the sea", time: 16.5},
    {line: "God I felt it when you left me", time: 17.5},

    {line: "It hit me hard", time: 18.5},
    {line: "In the car park", time: 19.5},
    {line: "Cause I was always looking", time: 20.5},
    {line: "For a spark", time: 21.5},

    {line: "Honey we can't lose", time: 23},
    {line: "When we make the rules", time: 23.5},
    {line: "But we never won", time: 24},
    {line: "Did we?", time: 24.5},
    
    {line: "And I'm going to make it", time: 26.5},
    {line: "anyway", time: 27.5},
    {line: "And I'm going to fake it", time: 29},
    {line: "baby", time: 29.5},
    
    {line: "I feel it now", time: 32.5},
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
  tweet.text !~ /RT/ && tweet.text !~ /@/ && tweet.text !~ /http/
end

def do_twitter_search_for_lyric(lyric)
  begin
    # search twitter
    chosen_tweet = Twitter.search("\"#{lyric[:line]}\"", :result_type => "recent").results.select{ |tweet| is_tweet_ok(tweet) }.first
    if chosen_tweet
      OpenStruct.new(text: chosen_tweet.text, link: "http://twitter.com/#{chosen_tweet.from_user_id}/status/#{chosen_tweet.id}", username: chosen_tweet.from_user, created_at: chosen_tweet.created_at)
    end
  rescue
    # oh the lols. so many lols.
    # development? ? raise : nil
    nil
  end
end

get '/' do
  content_type :json

  lyrics.map { |lyric|
    lyric[:tweet] = cache "lyrics_json_#{lyric[:time]}" do
      tweet_for_lyric(lyric) || ""
    end
    lyric
  }.to_json
end

configure :development do
  get '/cache/expire' do
    lyrics.map { |lyric|
      expire "lyrics_json_#{lyric[:time]}"
      lyric[:line]
    }.to_json
  end

  get '/cache/inspect' do
    send(:client).inspect
  end
end
