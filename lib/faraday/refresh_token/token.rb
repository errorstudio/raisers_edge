require 'faraday'

module Faraday
  class RefreshToken < Middleware
    class Token
      attr_reader :token, :expires_at

      def initialize(token, subscription_key, expires_at)
        @token = token
        @subscription_key = subscription_key
        @expires_at = expires_at
      end

      def headers
        {
          'Authorization' => "Bearer #{@token}",
          'bb-api-subscription-key' => @subscription_key
        }
      end

      def self.from_auth_code(access_token, subscription_key)
        new(access_token.token, subscription_key, access_token.expires_at)
      end
    end
  end
end
