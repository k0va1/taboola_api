require "spec_helper"
require "tempfile"

RSpec.describe TaboolaApi::Resources::MotionAds do
  let(:client_id) { "test_client_id" }
  let(:client_secret) { "test_client_secret" }
  let(:access_token) { "test_access_token" }
  let(:client) { TaboolaApi::Client.new(client_id: client_id, client_secret: client_secret, access_token: access_token) }
  let(:motion_ads) { described_class.new(client) }
  let(:account_id) { "test_account" }
  let(:campaign_id) { "test_campaign" }
  let(:item_id) { "test_item" }
  let(:base_url) { TaboolaApi::Client::DEFAULT_URL }

  describe "#get" do
    let(:endpoint) { "#{base_url}/#{account_id}/campaigns/#{campaign_id}/performance-video/items/#{item_id}" }
    let(:response_body) do
      {
        "id" => item_id,
        "title" => "Test Motion Ad",
        "url" => "https://example.com/landing-page",
        "video_url" => "https://cdn.taboola.com/videos/test_video.mp4",
        "fallback_url" => "https://cdn.taboola.com/images/test_fallback.jpg",
        "status" => "ACTIVE"
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

    it "fetches a specific motion ad item" do
      response = motion_ads.get(account_id, campaign_id, item_id)
      expect(response).to eq(JSON.parse(response_body))
      expect(WebMock).to have_requested(:get, endpoint)
        .with(headers: {"Authorization" => "Bearer #{access_token}", "Content-Type" => "application/json"})
    end
  end

  describe "#list_all" do
    let(:endpoint) { "#{base_url}/#{account_id}/campaigns/#{campaign_id}/performance-video/items" }
    let(:params) { {status: "ACTIVE", limit: 50} }
    let(:response_body) do
      {
        "results" => [
          {
            "id" => "item1",
            "title" => "Motion Ad 1",
            "status" => "ACTIVE",
            "video_url" => "https://cdn.taboola.com/videos/video1.mp4"
          },
          {
            "id" => "item2",
            "title" => "Motion Ad 2",
            "status" => "ACTIVE",
            "video_url" => "https://cdn.taboola.com/videos/video2.mp4"
          }
        ]
      }.to_json
    end

    context "when called with parameters" do
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

      it "returns a list of motion ad items with parameters" do
        response = motion_ads.list_all(account_id, campaign_id, params: params)
        expect(response).to eq(JSON.parse(response_body))
        expect(WebMock).to have_requested(:get, endpoint)
          .with(
            headers: {"Authorization" => "Bearer #{access_token}", "Content-Type" => "application/json"},
            query: params
          )
      end
    end
  end

  describe "#create" do
    let(:endpoint) { "#{base_url}/#{account_id}/campaigns/#{campaign_id}/performance-video/items" }
    let(:response_body) do
      {
        "id" => "new_item_id",
        "title" => "New Motion Ad",
        "url" => "https://example.com/landing-page",
        "video_url" => "https://cdn.taboola.com/videos/new_video.mp4",
        "fallback_url" => "https://cdn.taboola.com/images/new_fallback.jpg",
        "status" => "PROCESSING"
      }.to_json
    end

    let(:item_params) do
      {
        title: "New Motion Ad",
        url: "https://example.com/landing-page"
      }
    end

    context "with valid file objects" do
      let(:video_file) do
        file = Tempfile.new(["test_video", ".mp4"])
        file.write("fake video content")
        file.rewind
        file
      end

      let(:fallback_file) do
        file = Tempfile.new(["test_fallback", ".jpg"])
        file.write("fake image content")
        file.rewind
        file
      end

      before do
        stub_request(:post, endpoint)
          .with(
            headers: {
              "Authorization" => "Bearer #{access_token}",
              "Content-Type" => %r{multipart/form-data; boundary=.*}
            }
          )
          .to_return(status: 200, body: response_body, headers: {"Content-Type" => "application/json"})

        allow(MIME::Types).to receive(:type_for).with(video_file.path).and_return(MIME::Types["video/mp4"])
        allow(MIME::Types).to receive(:type_for).with(fallback_file.path).and_return(MIME::Types["image/jpeg"])
      end

      after do
        video_file.close
        video_file.unlink
        fallback_file.close
        fallback_file.unlink
      end

      it "creates a new motion ad with video and fallback image" do
        # Mock the creation of multipart objects to verify params
        expect(Faraday::Multipart::ParamPart).to receive(:new)
          .with(JSON.generate(item_params), "application/json")
          .and_call_original

        expect(Faraday::Multipart::FilePart).to receive(:new)
          .with(video_file, "video/mp4")
          .and_call_original

        expect(Faraday::Multipart::FilePart).to receive(:new)
          .with(fallback_file, "image/jpeg")
          .and_call_original

        response = motion_ads.create(
          account_id,
          campaign_id,
          video_file: video_file,
          fallback_file: fallback_file,
          params: item_params
        )

        expect(response).to eq(JSON.parse(response_body))

        expect(WebMock).to have_requested(:post, endpoint)
          .with { |req|
            req.headers["Content-Type"] =~ %r{multipart/form-data; boundary=.*} &&
              req.headers["Authorization"] == "Bearer #{access_token}" &&
              req.body.include?("fake video content") &&
              req.body.include?("fake image content") &&
              req.body.include?(JSON.generate(item_params))
          }
      end
    end

    context "with invalid file inputs" do
      it "raises ArgumentError when video_file is not a File or Tempfile" do
        fallback_file = Tempfile.new(["test_fallback", ".jpg"])

        expect {
          motion_ads.create(
            account_id,
            campaign_id,
            video_file: "not a file object",
            fallback_file: fallback_file
          )
        }.to raise_error(ArgumentError, "Video file must be provided")

        fallback_file.close
        fallback_file.unlink
      end

      it "raises ArgumentError when fallback_file is not a File or Tempfile" do
        video_file = Tempfile.new(["test_video", ".mp4"])

        expect {
          motion_ads.create(
            account_id,
            campaign_id,
            video_file: video_file,
            fallback_file: "not a file object"
          )
        }.to raise_error(ArgumentError, "Fallback image file must be provided")

        video_file.close
        video_file.unlink
      end
    end
  end

  describe "#update" do
    let(:endpoint) { "#{base_url}/#{account_id}/campaigns/#{campaign_id}/performance-video/items/#{item_id}" }
    let(:update_params) do
      {
        title: "Updated Motion Ad",
        status: "PAUSED"
      }
    end
    let(:response_body) do
      {
        "id" => item_id,
        "title" => "Updated Motion Ad",
        "url" => "https://example.com/landing-page",
        "video_url" => "https://cdn.taboola.com/videos/test_video.mp4",
        "fallback_url" => "https://cdn.taboola.com/images/test_fallback.jpg",
        "status" => "PAUSED"
      }.to_json
    end

    before do
      stub_request(:put, endpoint)
        .with(
          headers: {
            "Authorization" => "Bearer #{access_token}",
            "Content-Type" => "application/json"
          },
          body: update_params.to_json
        )
        .to_return(status: 200, body: response_body, headers: {"Content-Type" => "application/json"})
    end

    it "updates an existing motion ad" do
      response = motion_ads.update(account_id, campaign_id, item_id, params: update_params)
      expect(response).to eq(JSON.parse(response_body))
      expect(WebMock).to have_requested(:put, endpoint)
        .with(
          headers: {"Authorization" => "Bearer #{access_token}", "Content-Type" => "application/json"},
          body: update_params.to_json
        )
    end
  end
end
