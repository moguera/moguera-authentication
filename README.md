# Moguera::Authentication

Simple REST API Authentication.

[![Build Status](https://travis-ci.org/moguera/moguera-authentication.svg)](https://travis-ci.org/moguera/moguera-authentication)
[![Coverage Status](https://coveralls.io/repos/moguera/moguera-authentication/badge.png?branch=master)](https://coveralls.io/r/moguera/moguera-authentication?branch=master)

## Requirements

Ruby 2.1+

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
- request_path ```(env['REQUEST_PATH'])```
- request_method ```(env['REQUEST_METHOD'])```
- http_date ```(env['HTTP_DATE'])```
- content_type ```(env['CONTENT_TYPE'])```

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
A Rack middleware inserts a Moguera Authentication.

example config.ru

```ruby
require 'rack/moguera_authentication'
require 'server'
require 'json'

map '/' do
  run Public
end

map '/login' do
  # Add Rack::MogueraAuthentication somewhere in your rack stack
  use Rack::MogueraAuthentication do |request_access_key|

    # Search a secret_access_key by a request_access_key
    # # example credential.json
    # #=> {"user01":"secret"}
    file = File.join(File.expand_path(File.dirname(__FILE__)),'credential.json')
    secret_key = JSON.parse(File.open(file, &:read))[request_access_key]

    unless secret_key
      raise Moguera::Authentication::UserNotFound, "access_key: " + request_access_key
    end

    secret_key
  end
  
  run Private
end
```

example server.rb

```ruby
require 'sinatra/base'

class Public < Sinatra::Base
  post '/hello' do
    [200, {"Content-Type"=>"text/plain"}, ["Hello World!"]]
  end
end

class Private < Sinatra::Base
  post '/hello' do
    validate_user!
    [200, {"Content-Type"=>"text/plain"}, ["Hello #{env['moguera.auth'].access_key}!"]]
  end

  private

  def validate_user!
    if e = env['moguera.error']
      $stderr.puts e.message
      case e
        when Moguera::Authentication::ParameterInvalid,
             Moguera::Authentication::RequestTokenRequired
          halt 400, "400 Bad Request: #{e.message}\n"
        when Moguera::Authentication::AuthenticationError
          halt 401, "401 Unauthorized: #{e.message}\n"
        when Moguera::Authentication::UserNotFound
          halt 404, "404 Not Found: #{e.message}\n"
        else
          halt 500, "500 Internal Server Error\n"
      end
    end
  end
end
```

### Cilent

example client-faraday.rb

```ruby
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
```

### Quick Run

server

```
$ rackup sample/config.ru
```

client

```
$ sample/client-faraday.rb http://localhost:9292/hello
Hello World!

$ sample/client-faraday.rb http://localhost:9292/login/hello
Hello user01!
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/moguera-authentication/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Copyright

Copyright (c) 2015 hiro-su.

MIT License
