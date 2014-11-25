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
    user = JSON.parse(File.open('credential.json', &:read))
    user[key]
  end

  run Private
end
