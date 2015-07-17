$redis = Redis.new(url: ENV["REDIS_URL"]) # PRODUCTION
#$redis = Redis.new(:host => '127.0.0.1', :port => 6379) #DEVELOPMENT