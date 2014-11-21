require 'moguera/authentication/signature'

module Moguera
  class Authentication
    def initialize(apikey:, secret:, path:, method:, content_type:, date:, prefix: "MOGUERA")
      @signature = Signature.new(
          apikey: apikey,
          secret: secret,
          method: method,
          path: path,
          content_type: content_type,
          date: date,
          prefix: prefix
      )
    end

    attr_reader :signature

    def token
      @signature.token
    end
  end
end
