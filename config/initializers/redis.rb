if ENV["REDISCLOUD_URL"]
    #$redis = Redis.new(:host => '127.0.0.1', :port => 6379)
    $redis = Redis.new(:url => ENV["REDISCLOUD_URL"])
end