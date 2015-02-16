#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), %w(.. lib)))

require 'faraday/moguera_authentication'

url = ARGV[0]
abort "Usage: ruby #{__FILE__} http://localhost:9292/login/hello" unless url

access_key = 'user01'
secret_access_key = 'secret'

conn = Faraday.new do |faraday|
  faraday.use Faraday::MogueraAuthentication, access_key, secret_access_key
  faraday.response :logger
  faraday.adapter Faraday.default_adapter
end

payload = '{ "key" : "value" }'
response = conn.post(url, payload, 'Content-Type' => 'application/json')

puts response.body
