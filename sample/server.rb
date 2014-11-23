#!/usr/bin/env ruby
#
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), %w(.. lib)))

require 'sinatra'
require 'moguera/authentication'

post '/login' do
  begin
    request_token = Moguera::Authentication.new(request.env['HTTP_AUTHORIZATION'])
    user = request_token.authenticate! do |key|
      key_to_secret = 'secret'

      Moguera::Authentication::Request.new(
        access_key: key,
        secret_access_key: key_to_secret,
        request_path: request.env['REQUEST_PATH'],
        content_type: request.content_type,
        http_date: request.env['HTTP_DATE'],
        request_method: request.request_method
      )
    end
    return user.access_key
  rescue Moguera::Authentication::ParameterInvalid => e
    halt 400, "400 Bad Request: #{e.message}\n"
  rescue Moguera::Authentication::AuthenticationError => e
    params = %w(
      token access_key secret_access_key http_date
      request_method request_path content_type
    )
    msg = ["request_tooken: #{e.request_token}"]
    msg << params.map {|k| "server_#{k}: #{e.server_request.send(k)}" }
    logger.error msg * "\n"
    halt 401, "401 Unauthorized: #{e.message}\n"
  end
end

post '/login2' do
    request_token = Moguera::Authentication.new(request.env['HTTP_AUTHORIZATION'])
    user = request_token.authenticate do |key|
      key_to_secret = 'secret'

      Moguera::Authentication::Request.new(
        access_key: key,
        secret_access_key: key_to_secret,
        request_path: request.env['REQUEST_PATH'],
        content_type: request.content_type,
        http_date: request.env['HTTP_DATE'],
        request_method: request.request_method
      )
    end

    halt 401, "401 Unauthorized" unless user
    return user.access_key
end
