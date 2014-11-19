require 'moguera/authentication/signature'

module Moguera
  class Authentication
    def initialize(apikey, secret, path: nil, method: nil, content_type: nil)
      @signature = Signature.new(apikey, secret, method: method, path: path, content_type: content_type)
    end

    def apikey
      @signature.apikey
    end

    def secret
      @signature.secret
    end

    def token
      @signature.token
    end
  end
end
