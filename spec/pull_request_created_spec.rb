# frozen_string_literal: true

describe 'open pull request' do
  let(:mockserver) { 'http://localhost:9292' }
  let(:mockserver_default_headers) do
    {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json',
      'X-Pact-Mock-Service' => true
    }
  end

  let(:octokit_client) do
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
    Octokit::Client.new(bearer_token: github_app_installation_token[:token])
  end

  before do
    # remove previous test mocks
    RestClient::Request.execute(
      url: "#{mockserver}/interactions",
      method: :delete, headers: mockserver_default_headers,
    )

    # sets the mock in the mockserver
    RestClient::Request.execute(
      url: "#{mockserver}/interactions",
      method: :put, headers: mockserver_default_headers,
      payload: mockserver_contract_info.to_json
    )
  end

  context 'when no previous pull request was created for the branch' do
    let(:mockserver_contract_info) do
binding.pry
      include Pact::Matchers
      include Pact::SomethingLike

binding.pry
      # Pact.term

      {
        interactions: [
          {
            description: 'a request notifying pull request created',
            providerState: 'no previous pull request was created for the branch',
            request: {
              method: 'POST', path: '/',
              headers: {
                'Content-Type' => 'application/json',
                'User-Agent' => Pact.term(
                  generate: 'GitHub-Hookshot/123abcd',
                  matcher: /GitHub-Hookshot\/[a-z0-9]{7}/
                )
              },
              body: {
                action: 'opened',
                repository: {
                  id: Pact.term(
                    generate: 1234,
                    matcher: /[0-9]*/
                  ),
                  full_name: 'mooikos/test_webhook_pact'
                }
              }
              # body: Pact.term(
              #   generate: {
              #     action: 'opened',
              #     repository: {
              #       id: 1234,
              #       full_name: 'mooikos/test_webhook_pact'
              #     }
              #   },
              #   matcher: Pact::SomethingLike({
              #     action: 'opened',
              #     repository: Pact::SomethingLike({
              #       id: Pact::SomethingLike(1),
              #       full_name: 'mooikos/test_webhook_pact'
              #     })
              #   })
              # )
            },
            response: {
              status: 200,
              headers: {
                'Content-Type' => 'application/json'
              },
              body: { data: [] }
            }
          }
        ]
      }
    end

    it 'successfully process the message' do
      octokit_client.create_pull_request(
        'mooikos/test_webhook_pact', 'main', 'test_branch',
        'Test Pull Request', 'Test Pull Request Body'
      )
    end
  end
end
