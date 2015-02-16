#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), %w(.. lib)))

require 'moguera/authentication'
require 'httpclient'
require 'time'
require 'json'
require 'uri'

url = ARGV[0]
abort "Usage: ruby #{__FILE__} http://localhost:4567/login" unless url

http_client = HTTPClient.new
http_client.debug_dev = STDERR

request_path = URI.parse(url).path
request_path = '/' if request_path.empty?
http_date = Time.now.httpdate
content_type = 'application/json'

params = {
    access_key: 'user01',
    secret_access_key: 'secret',
    request_path: request_path,
    request_method: 'POST',
    content_type: content_type,
    http_date: http_date
}

request = Moguera::Authentication::Request.new(params)

headers = {
    'Authorization' => request.token,
    'Content-Type' => content_type,
    'Date' => http_date
}

response = http_client.post(url, {key:'value'}.to_json, headers)
puts response.body
