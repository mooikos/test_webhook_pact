# debugger
require 'pry-byebug'

# environment helper
require 'dotenv/load'

binding.pry

# rest client
# require 'rest-client'

# github api helper
require 'octokit'
## github authentication helper
require 'jwt'

# generate jwt token payload
current_timestamp = Time.now.to_i
expiration = current_timestamp + 60 * 5
github_app_id = 222_555
jwt_token_payload = { iat: current_timestamp, exp: expiration, iss: github_app_id }

# generate private rse private key
github_access_token = ENV.fetch('GITHUB_ACCESS_TOKEN')
openssl_private_key_rsa = OpenSSL::PKey::RSA.new(github_access_token)

jwt_token = JWT.encode(jwt_token_payload, openssl_private_key_rsa, 'RS256')

octokit_client = Octokit::Client.new(bearer_token: jwt_token)

# create pull request
octokit_client.create_pull_request(
  'XINGMobile/aruba', 'main', 'releases/github_webhook_api_test',
  'Test Pull Request', 'Test Pull Request Body'
)


binding.pry

puts 'hello'
