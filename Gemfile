# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in api_responder.gemspec.
gemspec

gem 'puma'

gem 'sqlite3'

group :development, :test do
  gem 'debug', '>= 1.0.0'
  gem 'rubocop'
  gem 'rubocop-minitest'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'simplecov'
end
