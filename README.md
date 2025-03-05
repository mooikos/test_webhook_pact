# test mobile github app pact

attempt to test the pact integration for mobile github app testing

## components

github app
- configured to [point to local](https://docs.github.com/en/webhooks/testing-and-troubleshooting-webhooks/testing-webhooks#testing-webhook-code-locally)
  - use [smee]()
    - create an entry on https://smee.io
    - start the smee proxy locally
      - `yarn smee -u https://smee.io/YlWcPA7V3ZBnGl --port 9292`
    - start a server that can receive info locally
    - configure the webhook on the mobile github app

spec runner
- beforeall: spawns a pact service recorder
- beforeeach: clear previous interactions
- setup interactions
- calls github api
  - configure connection via app token
- async verify interactions
- afterall: write interactions
- afterall: stops pact service recorder

## start pact mock server

PACT_DO_NOT_TRACK=true bundle exec pact-mock-service \
--consumer github \
--provider mobile_github_app \
--port 9292 \
--cors=CORS \
--pact-dir=./pacts/
