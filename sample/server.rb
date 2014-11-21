#!/usr/bin/env ruby
#
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), %w(.. lib)))

require 'sinatra'
require 'moguera/authentication'

post '/login' do
  begin
    request_token = Moguera::Authentication.new(request.env['HTTP_AUTHORIZATION'])
    request_token.authenticate! do |key|
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
  rescue Moguera::Authentication::ParameterInvalid => e
    halt 400, "400 Bad Request: #{e.message}\n"
  rescue Moguera::Authentication::AuthenticationError => e
    halt 401, "401 Unauthorized: #{e.message}\n"
  end
end
