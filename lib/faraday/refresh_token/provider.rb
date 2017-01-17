require 'faraday'
require 'active_support'
require 'oauth2/client'
require 'faraday/refresh_token/token'

module Faraday
  class RefreshToken
    class Provider < Middleware
      attr_reader :options, :client, :token

      def initialize(options)
        @options = options
        @cache   = options[:store] || ActiveSupport::Cache::MemoryStore.new
        @token   = setup_access_token
      end

      def setup_access_token
        token = get_token

        unless token
          token = Token.from_auth_code(oauth2_client.auth_code.get_token(@options[:options][:auth_code], redirect_uri: "http://localhost:3000/oauth/redirect"), @options[:options][:subscription_key])
          @cache.write(cache_key, token)
        end

        token
      end

      def get_token
        puts "Getting token: #{@cache.read(cache_key)}\n\n"
        @cache.read(cache_key)
      end

      def refresh_token
        token = @cache.read(cache_key)

        if token
          puts "Refreshing token..."
          token = token.refresh!
          @cache.write(cache_key, token, token.expires_at) if token
        else
          #todo: can we automate this?
          puts "NO token. Regenerate auth_code and restart..."
        end

        token
      end

      def get_token
        @cache.read(cache_key)
      end

      private
      def oauth2_client
        OAuth2::Client.new(@options[:id], @options[:secret], @options[:options])
      end

      def cache_key
        "refresh_token_#{@options[:id]}"
      end
    end
  end
end
