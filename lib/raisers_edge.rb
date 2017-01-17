require "raisers_edge/version"
require 'require_all'
require 'raisers_edge/connection'
require_rel 'raisers_edge/models'
require 'faraday/refresh_token'

require 'raisers_edge/engine' if defined?(Rails)

module RaisersEdge
  class << self
    attr_accessor :configuration, :debug_request
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
    self.configuration.configure_connection
  end

  class Configuration
    attr_accessor :client_id,
                  :client_secret,
                  :subscription_key,
                  :auth_code,
                  :base_url,
                  :api_path,
                  :logger,
                  :proxy,
                  :ssl_options

    attr_reader :connection

    def initialize
      @connection ||= Her::API.new
      @user_agent = "raisers_edge gem #{RaisersEdge::VERSION} (http://github.com/errorstudio/raisers_edge)"
      @base_url = "https://api.sky.blackbaud.com"
      @api_path = "constituent/v1"
      @ssl_options = {}
    end

    def user_agent=(agent)
      @user_agent = agent || @user_agent
    end

    def configure_connection
      if @client_id.nil? || @client_secret.nil?
        raise ArgumentError, "You need to add a client ID and client secret to connect to Raiser's Edge NXT."
      end

      @connection_path = "#{@base_url}/#{@api_path}"

      @connection.setup url: @connection_path, ssl: @ssl_options, proxy: @proxy do |c|
        # if @logger
        #   #Connection Debugging
        #   c.use RaisersEdge::DebugMiddleware, @logger
        # end

        #Oauth
        # c.request :oauth2_cached_token, provider: Faraday::OAuth2CachedToken::Provider.new({
        #   id: @client_id,
        #   secret: @client_secret,
        #   options: {
        #     site: "https://oauth2.sky.blackbaud.com",
        #     authorize_url: "/authorization",
        #     token_url: '/token'
        #   }
        # })

        c.request :refresh_token, provider: Faraday::RefreshToken::Provider.new({
          id: @client_id,
          secret: @client_secret,
          store: Rails.cache.class.new,
          options: {
            site: "https://oauth2.sky.blackbaud.com",
            authorize_url: "/authorization",
            token_url: "/token",
            subscription_key: @subscription_key,
            auth_code: @auth_code
          }
        })

        # Request
        c.use Faraday::Request::UrlEncoded

        # Response
        c.use Her::Middleware::DefaultParseJSON

        # Adapter
        c.use Faraday::Adapter::NetHttp
      end
    end
  end
end
