require "faraday"
require "faraday/multipart"
require "faraday/follow_redirects"
require "faraday/retry"
require "taboola_api/error"

module TaboolaApi
  class Client
    HOST = "https://backstage.taboola.com/backstage"
    CURRENT_API_PATH = "api/1.0"
    DEFAULT_URL = "#{HOST}/#{CURRENT_API_PATH}"

    def initialize(client_id:, client_secret:, access_token:)
      @client_id = client_id
      @client_secret = client_secret
      @access_token = access_token
    end

    def connection
      @connection ||= Faraday.new(url: DEFAULT_URL) do |conn|
        conn.headers["Authorization"] = "Bearer #{@access_token}"
        conn.headers["Content-Type"] = "application/json"

        conn.options.timeout = 60
        conn.options.open_timeout = 30

        conn.request :multipart
        conn.use Faraday::FollowRedirects::Middleware
        conn.use Faraday::Retry::Middleware, max: 3

        conn.response :json

        conn.adapter Faraday.default_adapter
      end
    end

    def request(method, path, params = {}, headers = {})
      url = File.join(DEFAULT_URL, path)

      response = connection.run_request(method, url, nil, headers) do |req|
        case method
        when :get, :delete
          req.params = params
        when :post, :put
          if headers["Content-Type"] == "multipart/form-data"
            req.options.timeout = 120
            req.body = {}
            params.each do |key, value|
              req.body[key.to_sym] = value
            end
          else
            req.body = JSON.generate(params) unless params.empty?
          end
        end
      end

      handle_response(response)
    end

    def handle_response(response)
      return response if response.success?

      status = response.status
      body = response.body
      error_message = body.is_a?(Hash) ? body&.dig("message") : body

      klass = case status
      when 401
        TaboolaApi::AuthenticationError
      when 403
        TaboolaApi::AuthorizationError
      when 429
        TaboolaApi::RateLimitError
      when 400..499
        TaboolaApi::InvalidRequestError
      when 500..599
        TaboolaApi::ApiError
      else
        TaboolaApi::Error
      end

      raise klass.new(error_message || "HTTP #{status}", status, body)
    end

    def update_access_token
      response = Faraday.post("#{HOST}/oauth/token") do |req|
        req.headers["Content-Type"] = "application/x-www-form-urlencoded"
        req.body = URI.encode_www_form(
          client_id: @client_id,
          client_secret: @client_secret,
          grant_type: "client_credentials"
        )
      end
      data = JSON.parse(response.body)

      @access_token = data["access_token"]
    end

    def accounts
      @accounts ||= TaboolaApi::Resources::Account.new(self)
    end

    def campaigns
      @campaigns ||= TaboolaApi::Resources::Campaign.new(self)
    end

    def campaign_items
      @campaign_items ||= TaboolaApi::Resources::CampaignItem.new(self)
    end

    def motion_ads
      @motion_ads ||= TaboolaApi::Resources::MotionAds.new(self)
    end

    def operations
      @operations ||= TaboolaApi::Resources::Operations.new(self)
    end

    def reportings
      @reportings ||= TaboolaApi::Resources::Reportings.new(self)
    end
  end
end
