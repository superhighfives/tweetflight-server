class TwitterSearcher

  SEARCH_RETRY_ATTEMPTS = 3

  def random_result(text)
    if tweet = search(text).sample
      log "Found: \"#{tweet.text}\". Retweeting..."

      unless ENV["NO_RETWEET"]
        Twitter.retweet(tweet.id) rescue nil
      end

      {
        text: sanitise_tweet_text(tweet.text),
        link: "http://twitter.com/#{tweet.user[:id]}/status/#{tweet.id}",
        username: tweet.from_user,
        created_at: tweet.created_at
      }
    else
      log "Nothing found :("
    end
  end

  def search(text)
    log "Searching twitter for \"#{text}\"..."
    attempts = 1
    begin
      Twitter.search('"' + text + '"', result_type: "recent").results.select{ |tweet| is_tweet_ok(tweet) }
    rescue Twitter::Error::ClientError => e
      log "Twitter returned an error: #{e.inspect}"
      if attempts <= SEARCH_RETRY_ATTEMPTS
        puts "Attempt #{attempts}. Retrying..."
        attempts += 1
        retry
      else
        puts "#{attempts} failed attempts. Giving up on tweet search."
        []
      end
    end
  end

  def is_tweet_ok(tweet)
    tweet.text !~ /RT/ && tweet.text !~ /@/ && tweet.text !~ /http/ && tweet.text !~ /#/ && tweet.text !~ /fuck/ && tweet.text !~ /nigga/ && tweet.text !~ /shit/ && tweet.text !~ /nigger/ && tweet.from_user != "legitnotch" && tweet.from_user != "765Days"
  end

  def sanitise_tweet_text(text)
    encoding_options = {
      :invalid           => :replace,  # Replace invalid byte sequences
      :undef             => :replace,  # Replace anything not defined in ASCII
      :replace           => '',        # Use a blank for those replacements
      :universal_newline => true       # Always break lines with \n
    }
    text.encode Encoding.find('ASCII'), encoding_options
  end

  def log(m)
    puts "[TwitterSearcher] #{m}"
  end

end
