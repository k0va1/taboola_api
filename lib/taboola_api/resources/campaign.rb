module TaboolaApi
  module Resources
    class Campaign < Base
      def list_all(account_id, params: {})
        response = client.request(:get, "#{account_id}/campaigns", params)
        response.body
      end

      def get(account_id, campaign_id)
        response = client.request(:get, "#{account_id}/campaigns/#{campaign_id}")
        response.body
      end
    end
  end
end
