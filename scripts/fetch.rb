require_relative '../app'

app = Sinatra::Application

Lyrics.all.each do |lyric|
  tweet = app.settings.twitter_searcher.random_result(lyric.line)
  app.settings.tweet_cache.set lyric, tweet
end
