require "mime/types"

module TaboolaApi
  module Resources
    class MotionAds < Base
      def get(account_id, campaign_id, item_id)
        response = client.request(:get, "#{account_id}/campaigns/#{campaign_id}/performance-video/items/#{item_id}")
        response.body
      end

      def list_all(account_id, campaign_id, params: {})
        response = client.request(:get, "#{account_id}/campaigns/#{campaign_id}/performance-video/items", params)
        response.body
      end

      def create(account_id, campaign_id, video_file:, fallback_file:, params: {})
        raise ArgumentError, "Video file must be provided" unless video_file.is_a?(File) || video_file.is_a?(Tempfile)
        raise ArgumentError, "Fallback image file must be provided" unless fallback_file.is_a?(File) || fallback_file.is_a?(Tempfile)

        video_mime_type = MIME::Types.type_for(video_file.path).first.to_s
        fallback_mime_type = MIME::Types.type_for(fallback_file.path).first.to_s

        payload = {
          new_item: Faraday::Multipart::ParamPart.new(
            JSON.generate(params),
            "application/json"
          ),
          video_file: Faraday::Multipart::FilePart.new(
            video_file,
            video_mime_type
          ),
          fallback_file: Faraday::Multipart::FilePart.new(
            fallback_file,
            fallback_mime_type
          )
        }
        headers = {"Content-Type" => "multipart/form-data"}
        response = client.request(:post, "#{account_id}/campaigns/#{campaign_id}/performance-video/items", payload, headers)
        response.body
      end

      def update(account_id, campaign_id, item_id, params: {})
        response = client.request(:put, "#{account_id}/campaigns/#{campaign_id}/performance-video/items/#{item_id}", params)
        response.body
      end
    end
  end
end
