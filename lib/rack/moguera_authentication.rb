require 'moguera/authentication'

module Rack
  # A Rack middleware inserts a Moguera Authentication.
  #
  # @example config.ru
  #   # Add Rack::MogueraAuthentication somewhere in your rack stack
  #   use Rack::MogueraAuthentication do |request_access_key|
  #
  #     # Search a secret_access_key by a request_access_key
  #     key_to_secret(request_access_key)
  #   end
  class MogueraAuthentication
    def initialize(app, &block)
      @app = app
      @secret_block = block
    end

    def call(env)
      begin
        request_token = Moguera::Authentication.new(env['HTTP_AUTHORIZATION'])
        user = request_token.authenticate! do |key|
          secret = @secret_block.call(key)
          params = build_parameter(key, secret, env)

          Moguera::Authentication::Request.new(params)
        end

        env['moguera.user'] = user
      rescue => e
        env['moguera.error'] = e
      end

      @app.call(env)
    end

    private

    def build_parameter(key, secret, env)
      {
          access_key: key,
          secret_access_key: secret,
          request_path: env['REQUEST_PATH'],
          request_method: env['REQUEST_METHOD'],
          content_type: env['CONTENT_TYPE'],
          http_date: env['HTTP_DATE']
      }
    end
  end
end
