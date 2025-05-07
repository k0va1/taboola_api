module TaboolaApi
  module Resources
    class Reportings < Base
      def top_campaign_content_report(account_id:, start_date:, end_date:, campaign: nil)
        params = {start_date: start_date, end_date: end_date, campaign: campaign}.compact
        response = client.request(:get, "#{account_id}/reports/top-campaign-content/dimensions/item_breakdown", params)
        response.body
      end
    end
  end
end
