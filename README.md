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
    user = JSON.parse(File.open('credential.json', &:read))
    user[key]
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
    [200, {"Content-Type"=>"text/plain"}, ["Hello #{env['moguera.user'].access_key}!"]]
  end

  private

  def validate_user!
    case e = env['moguera.error']
      when Moguera::Authentication::ParameterInvalid
        halt 400, "400 Bad Request: #{e.message}\n"
      when Moguera::Authentication::AuthenticationError
        halt 401, "401 Unauthorized: #{e.message}\n"
    end
  end
end
```

### Cilent

example rest-client

```ruby
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
  puts e.message
end
```

### Quick Run

server

```
$ cd samaple
$ rackup
```

client

```
$ ./client.rb http://localhost:9292/hello
Hello World!

$ ./client.rb http://localhost:9292/login/hello
Hello user01!
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