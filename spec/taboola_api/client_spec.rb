require "spec_helper"

RSpec.describe TaboolaApi::Client do
  let(:token_url) { "https://backstage.taboola.com/backstage/oauth/token" }
  let(:client) { described_class.new(client_id: "id", client_secret: "secret", access_token: "stale") }

  describe "#update_access_token" do
    it "returns the new access token and uses it for the following requests" do
      stub_request(:post, token_url).to_return(status: 200, body: {access_token: "fresh"}.to_json)
      accounts = stub_request(:get, "https://backstage.taboola.com/backstage/api/1.0/users/current/allowed-accounts")
        .with(headers: {"Authorization" => "Bearer fresh"})
        .to_return(status: 200, headers: {"Content-Type" => "application/json"}, body: {results: []}.to_json)
      client.connection

      expect(client.update_access_token).to eq("fresh")
      client.request(:get, "users/current/allowed-accounts")

      expect(accounts).to have_been_requested
    end

    it "raises AuthenticationError when the credentials are rejected with a non-JSON body" do
      body = "<BadClientCredentialsException><error>invalid_client</error></BadClientCredentialsException>"
      stub_request(:post, token_url).to_return(status: 401, body: body)

      expect { client.update_access_token }.to raise_error(TaboolaApi::AuthenticationError) { |error|
        expect(error.status_code).to eq(401)
        expect(error.body).to eq(body)
      }
    end

    it "raises AuthenticationError with the OAuth error description" do
      stub_request(:post, token_url).to_return(status: 400, body: {error: "invalid_client", error_description: "Bad client credentials"}.to_json)

      expect { client.update_access_token }.to raise_error(TaboolaApi::AuthenticationError, "Bad client credentials")
    end

    it "raises ApiError, not AuthenticationError, when Taboola is down" do
      stub_request(:post, token_url).to_return(status: 503, body: "<html>Service Unavailable</html>")

      expect { client.update_access_token }.to raise_error(TaboolaApi::ApiError)
    end

    it "raises RateLimitError when the token endpoint is rate limited" do
      stub_request(:post, token_url).to_return(status: 429, body: "")

      expect { client.update_access_token }.to raise_error(TaboolaApi::RateLimitError)
    end

    it "raises Error when a successful response carries no access token" do
      stub_request(:post, token_url).to_return(status: 200, body: "{}")

      expect { client.update_access_token }.to raise_error(TaboolaApi::Error, /HTTP 200/)
    end
  end
end
