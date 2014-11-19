module Moguera
  class Authentication
    class Signature
      def initialize(apikey, secret, path: nil, method: nil, content_type: nil)
        require 'time'
        require 'openssl'

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
        OpenSSL::HMAC.hexdigest(digest, @secret, seed)
      end

      def seed
        @apikey + @path + @method + Time.now.httpdate + @content_type
      end
    end
  end
end