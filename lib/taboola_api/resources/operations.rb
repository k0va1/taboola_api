require "mime/types"

module TaboolaApi
  module Resources
    class Operations < Base
      def upload_image(file)
        raise ArgumentError, "File must be provided" unless file.is_a?(File) || file.is_a?(Tempfile)

        mime_type = MIME::Types.type_for(file.path).first.to_s
        payload = {
          file: Faraday::Multipart::FilePart.new(file, mime_type)
        }
        response = client.request(:post, "operations/upload-image", payload, "Content-Type" => "multipart/form-data")
        response.body
      end
    end
  end
end
