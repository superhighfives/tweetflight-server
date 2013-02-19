# Preflight Tweets or Tweetflight or whatevs

First time running?

    brew install memcached

Then every other time

    /usr/local/opt/memcached/bin/memcached &
    bundle exec foreman start

## if there are problems

check https://github.com/caseman72/sinatra-dalli

You may need to manually set some vars to be kinda like

    if production?
      set :cache_server, ENV[:memcached_server]
    end

but FYI i have not checked if that is accurate.
