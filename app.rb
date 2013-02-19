# app.rb
require 'sinatra'
require 'sinatra/cross_origin'
require 'sinatra/dalli'
require 'json'

# dev mode easy lols
require 'sinatra/reloader' if development?

set :allow_origin, 'http://0.0.0.0:3501'
set :allow_methods, [:get, :post, :options]
set :allow_credentials, false

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
    {:line => 'Ascending', :time => 3.5}
  ]
end

def tweet_for_lyric(lyric)
  {:text => "", :link => "", :tweeter => "", :created_at => ""}
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

# for debugging, delete before deploying
get '/cache/expire' do
  expire "lyrics_json"
end

get '/cache/inspect' do
  send(:client).inspect
end
# end debugging code
