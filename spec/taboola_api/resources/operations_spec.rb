require "spec_helper"
require "tempfile"

RSpec.describe TaboolaApi::Resources::Operations do
  let(:client_id) { "test_client_id" }
  let(:client_secret) { "test_client_secret" }
  let(:access_token) { "test_access_token" }
  let(:client) { TaboolaApi::Client.new(client_id: client_id, client_secret: client_secret, access_token: access_token) }
  let(:operations) { described_class.new(client) }

  let(:base_url) { TaboolaApi::Client::DEFAULT_URL }
  let(:endpoint) { "#{base_url}/operations/upload-image" }

  describe "#upload_image" do
    context "when uploading a valid image file" do
      let(:image_file) do
        file = Tempfile.new(["test_image", ".jpg"])
        file.write("fake image content")
        file.rewind
        file
      end

      let(:response_body) do
        {
          "image_url" => "https://cdn.taboola.com/images/abcd1234.jpg",
          "width" => 800,
          "height" => 600,
          "size" => 24680,
          "format" => "JPEG"
        }.to_json
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
      end

      after do
        image_file.close
        image_file.unlink
      end

      it "uploads the image and returns image details" do
        response = operations.upload_image(image_file)
        expect(response).to eq(JSON.parse(response_body))

        expect(WebMock).to have_requested(:post, endpoint)
          .with { |req|
            req.headers["Content-Type"] =~ %r{multipart/form-data; boundary=.*} &&
              req.headers["Authorization"] == "Bearer #{access_token}" &&
              req.body.include?("fake image content")
          }
      end
    end
  end
end
