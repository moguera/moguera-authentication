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
        when Moguera::Authentication::ParameterInvalid
          halt 400, "400 Bad Request: #{e.message}\n"
        when Moguera::Authentication::AuthenticationError
          halt 401, "401 Unauthorized: #{e.message}\n"
        else
          halt 500, "500 Internal Server Error\n"
      end
    end
  end
end
