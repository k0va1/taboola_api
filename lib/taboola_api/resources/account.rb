module TaboolaApi
  module Resources
    class Account < Base
      def list_all
        response = client.request(:get, "users/current/allowed-accounts")
        response.body
      end
    end
  end
end
