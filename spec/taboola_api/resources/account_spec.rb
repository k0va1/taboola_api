require "spec_helper"

RSpec.describe TaboolaApi::Resources::Account do
  let(:client_id) { "test_client_id" }
  let(:client_secret) { "test_client_secret" }
  let(:access_token) { "test_access_token" }
  let(:client) { TaboolaApi::Client.new(client_id: client_id, client_secret: client_secret, access_token: access_token) }
  let(:account) { described_class.new(client) }

  let(:base_url) { TaboolaApi::Client::DEFAULT_URL }

  describe "#list_all" do
    let(:endpoint) { "#{base_url}/users/current/allowed-accounts" }

    context "when the request is successful" do
      let(:response_body) do
        {
          "results" => [
            {
              "id" => "account1",
              "name" => "Test Account 1",
              "type" => "ADVERTISER"
            },
            {
              "id" => "account2",
              "name" => "Test Account 2",
              "type" => "PUBLISHER"
            }
          ]
        }.to_json
      end

      before do
        stub_request(:get, endpoint)
          .with(
            headers: {
              "Authorization" => "Bearer #{access_token}",
              "Content-Type" => "application/json"
            }
          )
          .to_return(status: 200, body: response_body, headers: {"Content-Type" => "application/json"})
      end

      it "returns a list of all allowed accounts" do
        response = account.list_all
        expect(response).to eq(JSON.parse(response_body))
        expect(WebMock).to have_requested(:get, endpoint)
          .with(headers: {"Authorization" => "Bearer #{access_token}", "Content-Type" => "application/json"})
      end
    end

    context "when the response is empty" do
      let(:response_body) { {"results" => []}.to_json }

      before do
        stub_request(:get, endpoint)
          .with(
            headers: {
              "Authorization" => "Bearer #{access_token}",
              "Content-Type" => "application/json"
            }
          )
          .to_return(status: 200, body: response_body, headers: {"Content-Type" => "application/json"})
      end

      it "returns an empty results array" do
        response = account.list_all
        expect(response).to eq(JSON.parse(response_body))
        expect(response["results"]).to be_empty
      end
    end
  end
end
