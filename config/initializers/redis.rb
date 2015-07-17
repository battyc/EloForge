if ENV["HEROKU_REDIS_COBALT_URL"]

    $redis = Redis.new(:url => ENV["HEROKU_REDIS_COBALT_URL"])
end