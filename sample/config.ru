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
    user = JSON.parse(File.open(file, &:read))
    user[key]
  end

  run Private
end
