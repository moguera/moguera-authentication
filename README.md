# Moguera::Authentication

Simple REST API Authentication.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'moguera-authentication'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install moguera-authentication

## Authentication Logic
Use paramas

- access_key
- secret_access_key
- request_pah
- request_method
- http_date
- content_type

```ruby
string_to_isgn = access_key + request_path + request_method + http_date + conetnt_type
signature = Baes64.encode64(OpenSSL::HMAC.hexdigest(sha1, secret_access_key, string_to_sign)

Authorization header
Authorization: MOGUERA + " " + access_key + ":" + signature
```

Server check

1. Same request_token and server_token?
2. Expired the request?

## Usage

### Server
sinatra sample

```ruby
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
```

### Cilent
rest-client sample

```ruby
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
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/moguera-authentication/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Copyright

Copyright (c) 2014 hiro-su.

MIT License