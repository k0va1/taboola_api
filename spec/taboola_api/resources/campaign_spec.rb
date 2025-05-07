require "spec_helper"

RSpec.describe TaboolaApi::Resources::Campaign do
  let(:client_id) { "test_client_id" }
  let(:client_secret) { "test_client_secret" }
  let(:access_token) { "test_access_token" }
  let(:client) { TaboolaApi::Client.new(client_id: client_id, client_secret: client_secret, access_token: access_token) }
  let(:campaign) { described_class.new(client) }
  let(:account_id) { "test_account" }
  let(:campaign_id) { "test_campaign" }
  let(:base_url) { TaboolaApi::Client::DEFAULT_URL }

  describe "#list_all" do
    let(:endpoint) { "#{base_url}/#{account_id}/campaigns" }

    context "when called without parameters" do
      let(:response_body) do
        {
          "results" => [
            {
              "id" => "campaign1",
              "name" => "Test Campaign 1",
              "status" => "ACTIVE"
            },
            {
              "id" => "campaign2",
              "name" => "Test Campaign 2",
              "status" => "PAUSED"
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

      it "returns a list of all campaigns for the account" do
        response = campaign.list_all(account_id)
        expect(response).to eq(JSON.parse(response_body))
        expect(WebMock).to have_requested(:get, endpoint)
          .with(headers: {"Authorization" => "Bearer #{access_token}", "Content-Type" => "application/json"})
      end
    end

    context "when called with parameters" do
      let(:params) { {status: "ACTIVE", start_date: "2023-01-01", limit: 50} }
      let(:response_body) do
        {
          "results" => [
            {
              "id" => "campaign1",
              "name" => "Test Campaign 1",
              "status" => "ACTIVE"
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
            },
            query: params
          )
          .to_return(status: 200, body: response_body, headers: {"Content-Type" => "application/json"})
      end

      it "returns filtered campaigns using the provided parameters" do
        response = campaign.list_all(account_id, params: params)
        expect(response).to eq(JSON.parse(response_body))
        expect(WebMock).to have_requested(:get, endpoint)
          .with(
            headers: {"Authorization" => "Bearer #{access_token}", "Content-Type" => "application/json"},
            query: params
          )
      end
    end
  end

  describe "#get" do
    let(:endpoint) { "#{base_url}/#{account_id}/campaigns/#{campaign_id}" }

    context "when the campaign exists" do
      let(:response_body) do
        {
          "id" => campaign_id,
          "name" => "Test Campaign",
          "status" => "ACTIVE",
          "spending_limit" => 1000,
          "spending_limit_model" => "ENTIRE_CAMPAIGN",
          "cpc" => 0.5,
          "daily_cap" => 100,
          "start_date" => "2023-01-01",
          "end_date" => "2023-12-31"
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

      it "returns the campaign details" do
        response = campaign.get(account_id, campaign_id)
        expect(response).to eq(JSON.parse(response_body))
        expect(WebMock).to have_requested(:get, endpoint)
          .with(headers: {"Authorization" => "Bearer #{access_token}", "Content-Type" => "application/json"})
      end
    end
  end
end
