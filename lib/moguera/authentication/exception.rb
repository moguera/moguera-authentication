module Moguera
  class Authentication
    class AuthenticationError < StandardError; end
    class ParameterInvalid < StandardError; end
    class BlockRequired < StandardError; end
  end
end