require 'sinatra/base'

class Public < Sinatra::Base
  post '/' do
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
