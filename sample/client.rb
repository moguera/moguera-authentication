#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), %w(.. lib)))

require 'moguera/authentication'
require 'rest-client'
require 'time'
require 'json'
require 'uri'

url = ARGV[0]
abort 'Usage: ruby client.rb http://localhost:4567/login' unless url

request_path = URI.parse(url).path
request_method = 'POST'
http_date = Time.now.httpdate
content_type = 'application/json'

request_token = Moguera::Authentication::Request.new(
    access_key: 'apikey',
    secret_access_key: 'secret',
    request_path: request_path,
    request_method: request_method,
    http_date: http_date,
    content_type: content_type
).token

headers = {
    Authorization: request_token,
    content_type: content_type,
    Date: http_date
}

payload = { key: 'value' }.to_json

begin
  res = RestClient.post(url, payload, headers)
  puts res.code
rescue => e
  abort e.response
end
