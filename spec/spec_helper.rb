# debugger
require 'pry-byebug'

# environment helper
require 'dotenv/load'

# rest client
require 'rest-client'

# github api helper
require 'octokit'
## dependencies
require 'jwt'
require 'openssl'

# contract testing framework
require 'pact/consumer/rspec'

# See https://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.before(:suite) do
    # NOTE: only if pact specific environment is set would be likely convenient
    # setup pact-mock_service (see README)
    # do something
  end
end
