module Moguera
  class Authentication
    class AuthenticationError < StandardError
      attr_accessor :request_token
      attr_accessor :server_token
      attr_accessor :access_key
      attr_accessor :secret_access_key
      attr_accessor :request_method
      attr_accessor :request_path
      attr_accessor :content_type
      attr_accessor :http_date
    end

    class ParameterInvalid < StandardError
    end

    class BlockRequired < StandardError
    end
  end
end