module Moguera
  class Authentication
    class Request
      attr_accessor :token_prefix

      def initialize(access_key:, secret_access_key:, request_path:, request_method:, http_date:, content_type:)
        require 'time'
        require 'openssl'
        require 'base64'

        @access_key = access_key
        @secret_access_key = secret_access_key
        @request_path = request_path
        @request_method = request_method
        @http_date = http_date
        @content_type = content_type

        @token_prefix = token_prefix || 'MOGUERA'

        validate_parameter!
      end

      attr_reader :access_key, :secret_access_key, :request_path,
                  :request_method, :http_date, :content_type

      def token
        raise ParameterInvalid, 'Token prefix required.' if @token_prefix.nil?

        @token_prefix + ' ' + @access_key + ':' + signature
      end

      private

      def signature
        sha1 = OpenSSL::Digest::SHA1.new
        digest = OpenSSL::HMAC.hexdigest(sha1, @secret_access_key, string_to_sign)
        Base64.encode64(digest).strip
      end

      def string_to_sign
        @access_key + @request_path + @request_method + @http_date + @content_type
      end

      def validate_parameter!
        errors = []
        errors << 'Access Key' unless @access_key
        errors << 'Secret Access Key' unless @secret_access_key
        errors << 'Request Path' unless @request_path
        errors << 'Date Header' unless @http_date
        errors << 'Content-Type Header' unless @content_type

        raise ParameterInvalid, 'Missing: ' + errors * ', ' unless errors.empty?
      end
    end
  end
end