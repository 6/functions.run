ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
require 'database_cleaner'
require 'webmock/rspec'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.render_views
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.run_all_when_everything_filtered = true

  if ENV['CI']
    config.before(:example, :focus) { raise "Should not commit focused specs" }
  else
    config.filter_run focus: true
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end

def response_json
  json = JSON.parse(response.body)
  if json.is_a?(Array)
    json.map(&:with_indifferent_access)
  else
    json.with_indifferent_access
  end
end

def stub_session!(current_user = nil)
  current_user ||= FactoryGirl.create(:user)
  session[:user_id] = current_user.id
  current_user
end

def stub_api_key!(current_user = nil)
  current_user ||= FactoryGirl.create(:user)
  @request.headers['X-Api-Key'] = current_user.api_key
  current_user
end
