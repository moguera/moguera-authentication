module Moguera
  class Authentication
    class Signature
      def initialize(apikey:, secret:, path:, method:, content_type:, date:, prefix:)
        require 'time'
        require 'openssl'
        require 'base64'

        @apikey = apikey
        @secret = secret
        @path = path
        @method = method
        @date = date
        @content_type = content_type
        @prefix = prefix
      end

      attr_reader :apikey, :secret, :path, :method, :date, :content_type, :prefix

      def token
       @prefix + " " + @apikey + ":" + signature
      end

      private

      def signature
        digest = OpenSSL::Digest::SHA256.new
        Base64.encode64(OpenSSL::HMAC.hexdigest(digest, @secret, string_to_sign))
      end

      def string_to_sign
        @apikey + @path + @method + @date + @content_type
      end
    end
  end
end