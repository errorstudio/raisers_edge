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
      inject_header(request_env, @provider.get_token.headers)

      @app.call(request_env).on_complete do |response_env|
        on_complete(request_env, response_env)
      end
    end

    private

    def on_complete(request_env, response_env)
      if response_env.status == INVALID_TOKEN_STATUS
        puts "on_complete(request_env, response_env) response status == INVALID_TOKEN_STATUS (#{INVALID_TOKEN_STATUS})"

        inject_header(request_env, @provider.get_fresh_token.headers)
        @app.call(request_env)
      end
    end

    def inject_header(request_env, header)
      puts "inject_header(request_env, header)"

      headers = {
        'Authorization' => "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IjREVjZzVkxIM0FtU1JTbUZqMk04Wm5wWHU3WSJ9.eyJuYW1laWQiOiJiNThmNDhkYS1mNGYzLTQ0MmMtOTU0NC00MTA0M2VmZjA4YWEiLCJ0ZW5hbnRpZCI6Ijc2ZTVlMDYyLWRjYjgtNDFkNS1hNzEyLTc3OWJmM2MyNmZhMCIsImFwcGxpY2F0aW9uaWQiOiIwNTIwYTU5OS03NWNmLTRmMDMtYjgzNy04M2Y4ZDUzZDNjNmUiLCJQb2RJZCI6IlBvZDEiLCJpc3MiOiJodHRwczovL29hdXRoMi5za3kuYmxhY2tiYXVkLmNvbS8iLCJhdWQiOiJSRXgiLCJleHAiOjE0ODE4OTU5ODMsIm5iZiI6MTQ4MTg5MjM4M30.W-6mrcWSbRUMK0E649aJUIHydGKJsN496VvAqMTHUH28Xx6uZTMvVkvYMT8zmI3AuaZ7bruvu0HnsPfbyEOMpctxQlhulSBZXcJTAgoA7-_JEBanyZyUFoDYwQ48yK_0WJIiTR_1jQQhtebz1egPgi0gPZwmriHF0ZsgstlbvHluDs1-OrQv0FsQTZ8ROAevS6U-UIS29puh1daAnOT30wcwk2NlJS_yYb4o1VgQSPQbr2EUoQZ1DY6dnn3u1GOKzv-fADsEII1lxHnhZI2FHwHwXgH5gmjpOmGlyfOORL_1bkaZfvhsyhVFKcskNvnpnJrXTU7Fn6rfWSxe9TWvhA",
        'bb-api-subscription-key' => "d65bc301fbe94dee80a5392adbdac316"
      }

      request_env[:request_headers].merge!(headers)
    end
  end
end

Faraday::Request.register_middleware refresh_token: Faraday::RefreshToken
