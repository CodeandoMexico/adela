source 'http://rubygems.org'

ruby '2.1.4'

gem 'rails', '4.1'

gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'jquery-ui-sass-rails'
gem 'active_model_serializers'
gem 'jbuilder', '~> 2.0'
gem 'devise'
gem 'bootstrap-sass'
gem 'carrierwave'
gem 'carrierwave-aws'
gem 'i18n'
gem 'friendly_id'
gem 'pg'
gem 'eco'
gem 'redis'
gem 'sidekiq'
gem 'figaro'
gem 'will_paginate', '~> 3.0'
gem 'rack-pjax'
gem 'route_translator'

gem 'ckan', :git => 'https://github.com/zoek1/CKAN.git'

group :development, :test do
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'rspec-rails'
  gem 'debugger'
  gem 'factory_girl_rails'
  gem 'letter_opener'
  gem 'thin'
end

group :test do
  gem 'selenium-webdriver'
  gem 'capybara'
  gem 'database_cleaner'
end

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :staging, :production do
  gem 'unicorn'
end

# Dev tools and plugins
gem 'coveralls', require: false
