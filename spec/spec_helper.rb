require "taboola_api"
require "webmock/rspec"

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Clean up WebMock after each test
  config.after(:each) do
    WebMock.reset!
  end

  WebMock.disable_net_connect!(allow_localhost: true)
end
