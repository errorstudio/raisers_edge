require 'faraday'

module Faraday
  class RefreshToken < Middleware
    class Token
      def initialize(token, subscription_key, expires_at)
        @token = token
        @subscription_key = subscription_key
        @expires_at = expires_at
      end

      def headers
        {
          'Authorization' => "Bearer #{@token}",
          'bb-api-subscription-key' => @subscription_key,
          'x' => 'y'
        }
      end

      def refresh_token_body
        {
          grant_type: "refresh_token",
          refresh_token: "8897753d21d54415955f5f1c67e8481e"
        }
      end

      def self.from_access_token(access_token)
        new(access_token.token, access_token.expires_at)
      end
    end
  end
end
