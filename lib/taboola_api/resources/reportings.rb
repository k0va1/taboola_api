module TaboolaApi
  module Resources
    class Reportings < Base
      def top_campaign_content_report(account_id:, start_date:, end_date:, campaign: nil)
        params = {start_date: start_date, end_date: end_date, campaign: campaign}.compact
        response = client.request(:get, "#{account_id}/reports/top-campaign-content/dimensions/item_breakdown", params)
        response.body
      end

      def realtime_campaign_report(account_id:, dimension:, params: {})
        raise ArgumentError, "start_date and end_date params are required" unless params[:start_date] && params[:end_date]

        response = client.request(:get, "#{account_id}/reports/reports/realtime-campaign-summary/dimensions/#{dimension}", params)
        response.body
      end

      def realtime_ads_report(account_id:, dimension:, params: {})
        raise ArgumentError, "start_date and end_date params are required" unless params[:start_date] && params[:end_date]

        response = client.request(:get, "#{account_id}/reports/reports/realtime-top-campaign-content/dimensions/#{dimension}", params)
        response.body
      end
    end
  end
end
