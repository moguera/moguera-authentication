require 'moguera/authentication/version'
require 'moguera/authentication/request'
require 'moguera/authentication/exception'

module Moguera
  class Authentication
    attr_accessor :allow_time_interval

    def initialize(token = nil)
      raise AuthenticationError, 'Missing request token.' unless token

      @token = token
      @allow_time_interval = allow_time_interval || 600
    end

    def authenticate(&block)
      raise BlockRequired, 'Request token required.' unless block_given?

      _, apikey_signature = @token.split
      apikey, _ = apikey_signature.split(':')
      server_request = block.call(apikey)

      validate_token!(server_token: server_request.token, request_token: @token)
      validate_time!(request_time: server_request.http_date)

      server_request
    end

    private

    def validate_token!(server_token:, request_token:)
      unless server_token == request_token
        raise AuthenticationError, 'Invalid token.'
      end
    end

    def validate_time!(request_time:)
      return true if @allow_time_interval.nil?

      raise ParameterInvalid, 'Please input a positive value.' if @allow_time_interval <= 0

      rt = Time.parse(request_time).to_i
      st = Time.now.to_i

      interval = (st - rt).abs
      if interval >= @allow_time_interval
        raise AuthenticationError, 'Expired request.'
      end
    end
  end
end
