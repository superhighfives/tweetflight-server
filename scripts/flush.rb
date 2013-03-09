require_relative '../app'

app = Sinatra::Application

Lyrics.all do |lyric|
  app.settings.tweet_cache.delete lyric
end
