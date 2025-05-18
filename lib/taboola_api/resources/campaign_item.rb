module TaboolaApi
  module Resources
    class CampaignItem < Base
      def get(account_id, campaign_id, item_id)
        response = client.request(:get, "#{account_id}/campaigns/#{campaign_id}/items/#{item_id}")
        response.body
      end

      def list_all(account_id, campaign_id, params: {})
        response = client.request(:get, "#{account_id}/campaigns/#{campaign_id}/items", params)
        response.body
      end

      def create(account_id, campaign_id, params: {})
        response = client.request(:post, "#{account_id}/campaigns/#{campaign_id}/items", params)
        response.body
      end

      def update(account_id, campaign_id, item_id, params: {})
        response = client.request(:post, "#{account_id}/campaigns/#{campaign_id}/items/#{item_id}", params)
        response.body
      end

      def delete(account_id, campaign_id, item_id)
        response = client.request(:delete, "#{account_id}/campaigns/#{campaign_id}/items/#{item_id}")
        response.body
      end
    end
  end
end
