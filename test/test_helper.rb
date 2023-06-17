# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require 'simplecov'

SimpleCov.start 'rails' do
  add_filter 'lib/mini_api/version.rb'
end

require_relative "../test/dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../test/dummy/db/migrate", __dir__)]
require "rails/test_help"


I18n.enforce_available_locales = true
I18n.load_path << File.expand_path("../locales/en.yml", __FILE__)
I18n.reload!

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("fixtures", __dir__)
  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
  ActiveSupport::TestCase.file_fixture_path = ActiveSupport::TestCase.fixture_path + "/files"
  ActiveSupport::TestCase.fixtures :all
end

class DummyRecord < ActiveRecord::Base
  validates :first_name, presence: true
  validates :last_name, presence: true
end
