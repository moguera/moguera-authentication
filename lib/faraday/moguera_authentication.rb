require 'faraday'
require 'moguera/authentication'
require 'time'

module Faraday
  class MogueraAuthentication < Faraday::Middleware
    def initialize(app, access_key, secret_access_key)
      super(app) # @app = app
      @access_key = access_key
      @secret_access_key = secret_access_key
    end

    def call(env)
      params = build_parameter(env)
      request = Moguera::Authentication::Request.new(params)
      headers = {
          'Authorization' => request.token,
          'Content-Type' => params[:content_type],
          'Date' => params[:http_date]
      }
      env.request_headers.merge!(headers)
      @app.call(env)
    end

    private

    def build_parameter(env)
      path = env.url.path
      method = "#{env.method}".upcase
      headers = env.request_headers
      {
          access_key: @access_key,
          secret_access_key: @secret_access_key,
          request_path: path,
          request_method: method,
          content_type: headers['Content-Type'],
          http_date: headers['Date'] || Time.now.httpdate
      }
    end
  end
end
