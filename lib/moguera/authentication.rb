require 'moguera/authentication/signature'

module Moguera
  class Authentication
    def initialize(apikey:, secret:, path:, method:, content_type:)
      @signature = Signature.new(
          apikey: apikey,
          secret: secret,
          method: method,
          path: path,
          content_type: content_type
      )
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
