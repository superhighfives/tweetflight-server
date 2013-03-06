# Preflight Nerves (server)

## Installation
First time running?

    brew install memcached

Then every other time

    /usr/local/opt/memcached/bin/memcached &
    bundle exec foreman start

Make sure you make a .env file like sample.env so the twitter auth works.

You also need to make sure the correct values are set on heroku via

  heroku config:add TWITTER_CONSUMER_KEY blahblahblah
  ...
  etc

## License
This code (not including the lyrics) is licensed under a [Creative Commons Attribution License](http://creativecommons.org/licenses/by/3.0/): you may use it, but you must give attribution.