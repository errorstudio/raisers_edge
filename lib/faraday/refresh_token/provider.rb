require 'faraday'
require 'active_support'
require 'oauth2/client'
require 'faraday/refresh_token/token'

module Faraday
  class RefreshToken
    class Provider < Middleware
      attr_reader :client, :token

      def initialize(options)
        @options = options
        @cache   = options[:store] || ActiveSupport::Cache::MemoryStore.new

        byebug
        @client  = OAuth2::Client.new(@options[:id], @options[:secret], @options[:options])
        @token   = @client.auth_code.get_token(@options[:options][:auth_code], redirect_uri: "http://localhost:3000/oauth/redirect")
      end

      def get_fresh_token
        code          = "c15f2a4c28eb48599479ff3d27bdb725"
        token_options = {redirect_uri: "http://localhost:3000/oauth/redirect"}

        token = @token.refresh!
        @cache.write(cache_key, token, expires_in: 9999999999)
        token
      end

      def get_token
        get_fresh_token
        @cache.read(cache_key) || get_fresh_token
      end

      private
      def cache_key
        "refresh_token_#{@options[:id]}"
      end
    end
  end
end
