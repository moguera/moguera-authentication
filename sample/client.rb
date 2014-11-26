#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), %w(.. lib)))

require 'moguera/authentication'
require 'rest-client'
require 'time'
require 'json'
require 'uri'

url = ARGV[0]
abort "Usage: ruby #{__FILE__} http://localhost:4567/login" unless url

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
    Authorization: request.token,
    content_type: content_type,
    Date: http_date
}

begin
  res = RestClient.post(url, {key:'value'}.to_json, headers)
  puts res.body
rescue => e
  puts e.response
end
