# Preflight Tweets or Tweetflight or whatevs

First time running?

    brew install memcached

Then every other time

    /usr/local/opt/memcached/bin/memcached &
    bundle exec foreman start

make sure you make a .env file like sample.env so the twitter auth works.

You also need to make sure the correct values are set on heroku via

  heroku config:add TWITTER_CONSUMER_KEY blahblahblah
  ...
  etc

But I already did that.
