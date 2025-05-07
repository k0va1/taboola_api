require "spec_helper"

RSpec.describe TaboolaApi::Resources::CampaignItem do
  let(:client_id) { "test_client_id" }
  let(:client_secret) { "test_client_secret" }
  let(:access_token) { "test_access_token" }
  let(:client) { TaboolaApi::Client.new(client_id: client_id, client_secret: client_secret, access_token: access_token) }
  let(:campaign_item) { described_class.new(client) }

  let(:account_id) { "test_account" }
  let(:campaign_id) { "test_campaign" }
  let(:item_id) { "test_item" }

  let(:base_url) { TaboolaApi::Client::DEFAULT_URL }

  describe "#get" do
    let(:endpoint) { "#{base_url}/#{account_id}/campaigns/#{campaign_id}/items/#{item_id}" }
    let(:response_body) { {"id" => item_id, "title" => "Test Item"}.to_json }

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

    it "fetches a specific campaign item" do
      response = campaign_item.get(account_id, campaign_id, item_id)
      expect(response).to eq(JSON.parse(response_body))
      expect(WebMock).to have_requested(:get, endpoint)
        .with(headers: {"Authorization" => "Bearer #{access_token}", "Content-Type" => "application/json"})
    end
  end

  describe "#list_all" do
    let(:endpoint) { "#{base_url}/#{account_id}/campaigns/#{campaign_id}/items" }
    let(:params) { {limit: 10, offset: 0} }
    let(:response_body) { {"items" => [{"id" => "item1"}, {"id" => "item2"}]}.to_json }

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

    it "lists all campaign items with optional parameters" do
      response = campaign_item.list_all(account_id, campaign_id, params: params)
      expect(response).to eq(JSON.parse(response_body))
      expect(WebMock).to have_requested(:get, endpoint)
        .with(
          headers: {"Authorization" => "Bearer #{access_token}", "Content-Type" => "application/json"},
          query: params
        )
    end

    it "lists all campaign items without parameters" do
      stub_request(:get, endpoint)
        .with(headers: {"Authorization" => "Bearer #{access_token}", "Content-Type" => "application/json"})
        .to_return(status: 200, body: response_body, headers: {"Content-Type" => "application/json"})

      response = campaign_item.list_all(account_id, campaign_id)
      expect(response).to eq(JSON.parse(response_body))
      expect(WebMock).to have_requested(:get, endpoint)
        .with(headers: {"Authorization" => "Bearer #{access_token}", "Content-Type" => "application/json"})
    end
  end

  describe "#create" do
    let(:endpoint) { "#{base_url}/#{account_id}/campaigns/#{campaign_id}/items" }
    let(:item_params) do
      {
        url: "https://example.com/item1",
        title: "Test Item",
        image_url: "https://example.com/image.jpg"
      }
    end
    let(:response_body) { {"id" => "new_item_id", "status" => "ACTIVE"}.to_json }

    before do
      stub_request(:post, endpoint)
        .with(
          headers: {
            "Authorization" => "Bearer #{access_token}",
            "Content-Type" => "application/json"
          },
          body: item_params.to_json
        )
        .to_return(status: 200, body: response_body, headers: {"Content-Type" => "application/json"})
    end

    it "creates a new campaign item" do
      response = campaign_item.create(account_id, campaign_id, params: item_params)
      expect(response).to eq(JSON.parse(response_body))
      expect(WebMock).to have_requested(:post, endpoint)
        .with(
          headers: {"Authorization" => "Bearer #{access_token}", "Content-Type" => "application/json"},
          body: item_params.to_json
        )
    end
  end

  describe "#update" do
    let(:endpoint) { "#{base_url}/#{account_id}/campaigns/#{campaign_id}/items/#{item_id}" }
    let(:update_params) do
      {
        title: "Updated Title",
        status: "PAUSED"
      }
    end
    let(:response_body) { {"id" => item_id, "title" => "Updated Title", "status" => "PAUSED"}.to_json }

    before do
      stub_request(:post, endpoint)
        .with(
          headers: {
            "Authorization" => "Bearer #{access_token}",
            "Content-Type" => "application/json"
          },
          body: update_params.to_json
        )
        .to_return(status: 200, body: response_body, headers: {"Content-Type" => "application/json"})
    end

    it "updates an existing campaign item" do
      response = campaign_item.update(account_id, campaign_id, item_id, params: update_params)
      expect(response).to eq(JSON.parse(response_body))
      expect(WebMock).to have_requested(:post, endpoint)
        .with(
          headers: {"Authorization" => "Bearer #{access_token}", "Content-Type" => "application/json"},
          body: update_params.to_json
        )
    end
  end

  describe "error handling" do
    let(:endpoint) { "#{base_url}/#{account_id}/campaigns/#{campaign_id}/items/#{item_id}" }

    context "when API returns an error" do
      before do
        stub_request(:get, endpoint)
          .to_return(
            status: 401,
            body: {"message" => "Unauthorized access"}.to_json,
            headers: {"Content-Type" => "application/json"}
          )
      end

      it "raises an appropriate error" do
        expect {
          campaign_item.get(account_id, campaign_id, item_id)
        }.to raise_error(TaboolaApi::AuthenticationError, "Unauthorized access")
      end
    end

    context "when API returns a rate limit error" do
      before do
        stub_request(:get, endpoint)
          .to_return(
            status: 429,
            body: {"message" => "Rate limit exceeded"}.to_json,
            headers: {"Content-Type" => "application/json"}
          )
      end

      it "raises a rate limit error" do
        expect {
          campaign_item.get(account_id, campaign_id, item_id)
        }.to raise_error(TaboolaApi::RateLimitError, "Rate limit exceeded")
      end
    end
  end
end
