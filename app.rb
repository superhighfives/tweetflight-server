# app.rb
require 'sinatra'
require 'sinatra/cross_origin'
require 'sinatra/dalli'
require 'json'
require 'twitter'
require 'ostruct'

# dev mode easy lols
require 'sinatra/reloader' if development?

# cross domain
set :allow_origin, 'http://localhost:3501'
set :allow_methods, [:get, :post, :options]
set :allow_credentials, false

# dalli settings
set :cache_default_expiry, 1
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
    {:line => 'It was dark', :time => 1},
    {:line => 'In the car park', :time => 2},
    {:line => 'I heard a lark', :time => 3},
    {:line => 'Ascending', :time => 3.5},
    {:line => 'And you laughed', :time => 4}
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
  tweet.text !~ /RT/ && tweet.text !~ /@/
end

def do_twitter_search_for_lyric(lyric)
  begin
    # search twitter
    tweet = Twitter.search("\"#{lyric[:line]}\"", :result_type => "recent").select{ |tweet| is_tweet_ok(tweet) }.first
    OpenStruct.new(text: tweet.text, link: "http://twitter.com/#{tweet.from_user_id}/status/#{tweet.id}", username: tweet.from_user, created_at: tweet.created_at)
  rescue
    nil
  end
end

get '/' do
  content_type :json

  cache "lyrics_json" do
    lyrics.map { |lyric|
      lyric[:tweet] = tweet_for_lyric(lyric)
      lyric
    }.to_json
  end
end

configure :development do
  get '/cache/expire' do
    expire "lyrics_json"
  end

  get '/cache/inspect' do
    send(:client).inspect
  end
end