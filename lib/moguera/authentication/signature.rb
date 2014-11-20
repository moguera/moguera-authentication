module Moguera
  class Authentication
    class Signature
      def initialize(apikey:, secret:, path:, method:, content_type:)
        require 'time'
        require 'openssl'
        require 'base64'

        @apikey = apikey
        @secret = secret
        @path = path
        @method = method
        @content_type = content_type
      end

      attr_reader :apikey

      def token
        @apikey + ":" + signature
      end

      private

      def signature
        digest = OpenSSL::Digest::SHA256.new
        Base64.encode64(OpenSSL::HMAC.hexdigest(digest, @secret, seed))
      end

      def seed
        @apikey + @path + @method + Time.now.httpdate + @content_type
      end
    end
  end
end