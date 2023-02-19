class TweetCache

  def initialize(memcached_client)
    @client = memcached_client
  end
  
  def get(lyric)
    @client.get cache_key(lyric)
  end

  def set(lyric, tweet)
    @client.set cache_key(lyric), tweet
  end

  def delete(lyric)
    @client.delete cache_key(lyric)
  end

  def cache_key(lyric)
    lyric.id.to_s
  end

end