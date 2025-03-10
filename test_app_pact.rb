# debugger
require 'pry-byebug'

# environment helper
require 'dotenv/load'

# rest client
# require 'rest-client'

# github api helper
require 'octokit'
## dependencies
require 'jwt'
require 'openssl'

##### GENERATE GITHUB API ACCESS (START)
# https://github.com/octokit/octokit.rb?tab=readme-ov-file#github-app
# https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/generating-a-json-web-token-jwt-for-a-github-app#generating-a-json-web-token-jwt
# https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/managing-private-keys-for-github-apps#generating-private-keys

# privacy enhanced email (PEM)
github_app_private_pem = ENV.fetch('GITHUB_APP_PRIVATE_PEM')
github_app_private_key = OpenSSL::PKey::RSA.new(github_app_private_pem, 'RS256')

# generate the jwt token
github_app_client_id = ENV.fetch('GITHUB_APP_CLIENT_ID')
github_app_jwt_token_payload = {
  # issued at time, 60 seconds in the past to allow for clock drift
  iat: Time.now.to_i - 60,
  # expiration time, 10 minute maximum
  exp: Time.now.to_i + (10 * 60),
  # gitHub app client ID
  iss: github_app_client_id,
  # message algorithm
  alg: 'RS256'
}
github_app_jwt_token = JWT.encode(github_app_jwt_token_payload, github_app_private_key, 'RS256')

# oktokit client setup
octokit_client_setup = Octokit::Client.new(bearer_token: github_app_jwt_token)
github_app_installation_id = ENV.fetch('GITHUB_APP_INSTALLATION_ID')
github_app_installation_token = octokit_client_setup.create_app_installation_access_token(github_app_installation_id)
##### GENERATE GITHUB API ACCESS (END)

# octokit client instance
octokit_client = Octokit::Client.new(bearer_token: github_app_installation_token[:token])

binding.pry

# check that it works
octokit_client.app

# check the repo
octokit_client.repo('mooikos/test_webhook_pact')

# create pull request
octokit_client.create_pull_request(
  'mooikos/test_webhook_pact', 'main', 'test_branch',
  'Test Pull Request', 'Test Pull Request Body'
)

puts '## THE END !!'
