module Moguera
  class Authentication
    class AuthenticationError < StandardError
      attr_accessor :server_request
      attr_accessor :request_token
    end

    class ParameterInvalid < StandardError
    end

    class BlockRequired < StandardError
    end

    class RequestTokenRequired < StandardError
    end

    class UserNotFound < StandardError
    end
  end
end