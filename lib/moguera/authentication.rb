require 'moguera/authentication/exception'

module Moguera
  class Authentication
    attr_accessor :token_prefix, :allow_time_interval

    def initialize(apikey:, secret:, path:, method:, date:, content_type:)
      require 'time'
      require 'openssl'
      require 'base64'

      @apikey = apikey
      @secret = secret
      @path = path
      @method = method
      @date = date
      @content_type = content_type

      @token_prefix = token_prefix || "MOGUERA"
      @allow_time_interval = allow_time_interval || 600
    end

    attr_reader :apikey, :secret, :path, :method, :date, :content_type

    def token
      raise ParameterInvalid, "Token prefix required." if @token_prefix.nil?

      @token_prefix + " " + @apikey + ":" + signature
    end

    def authenticate(&block)
      raise BlockRequired, "Request token required." unless block_given?

      request_token = block.call
      validate_token!(server_token: token, request_token: request_token)
      validate_time!(request_time: @date)

      self
    end

    private

    def signature
      digest = OpenSSL::Digest::SHA1.new
      Base64.encode64(OpenSSL::HMAC.hexdigest(digest, @secret, string_to_sign))
    end

    def string_to_sign
      @apikey + @path + @method + @date + @content_type
    end

    def validate_token!(server_token:, request_token:)
      unless server_token == request_token
        raise AuthenticationError, "Invalid token."
      end
    end

    def validate_time!(request_time:)
      return true if @allow_time_interval.nil?

      raise ParameterInvalid, "Please input a positive value." if @allow_time_interval <= 0

      rt = Time.parse(request_time).to_i
      st = Time.now.to_i

      interval = (st - rt).abs
      if interval >= @allow_time_interval
        raise AuthenticatoinError, "Expired request."
      end
    end
  end
end
