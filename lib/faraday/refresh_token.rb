require 'faraday'
require 'faraday/refresh_token/provider'

module Faraday
  class RefreshToken < Middleware
    INVALID_TOKEN_STATUS = 401

    attr_reader :provider

    def initialize(app, options = {})
      super(app)

      @provider = options[:provider] || Provider.new(options[:provider_options] || {})
      @logger   = options[:logger]
    end

    def call(request_env)
      token_headers = @provider.token.headers
      inject_header(request_env, token_headers)

      @app.call(request_env).on_complete do |response_env|
        on_complete(request_env, response_env)
      end
    end

    private

    def on_complete(request_env, response_env)
      if response_env.status == INVALID_TOKEN_STATUS
        puts "on_complete(request_env, response_env) response status == INVALID_TOKEN_STATUS (#{INVALID_TOKEN_STATUS})"

        inject_header(request_env, @provider.refresh_token.headers)
        @app.call(request_env)
      end
    end

    def inject_header(request_env, header)
      request_env[:request_headers].merge!(header)
    end
  end
end

Faraday::Request.register_middleware refresh_token: Faraday::RefreshToken
