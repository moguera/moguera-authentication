$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), %w(.. lib)))

require 'rack/moguera_authentication'
require 'server'
require 'json'

map '/' do
  run Public
end

map '/login' do
  use Rack::MogueraAuthentication do |key|
    file = File.join(File.expand_path(File.dirname(__FILE__)), 'credential.json')
    secret_key = JSON.parse(File.open(file, &:read))[key]

    raise Moguera::Authentication::UserNotFound unless secret_key

    secret_key
  end

  run Private
end
