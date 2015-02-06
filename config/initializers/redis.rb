uri = URI.parse(ENV["REDISTOGO_URL"]) unless Rails.env.test?
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password) unless Rails.env.test?