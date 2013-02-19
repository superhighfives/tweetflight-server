# app.rb
require 'sinatra'
require 'sinatra/cross_origin'
require 'json'

set :allow_origin, 'http://0.0.0.0:3501'
set :allow_methods, [:get, :post, :options]
set :allow_credentials, false

configure do
  enable :cross_origin
end

before do
  response.headers["Access-Control-Allow-Headers"] = "x-requested-with"
end

lyrics = [
  {:line => 'It was dark', :time => 1},
  {:line => 'In the car park', :time => 2},
  {:line => 'I heard a lark', :time => 3},
  {:line => 'Ascending', :time => 3.5}
]

get '/' do
  content_type :json
  lyrics.to_json
end