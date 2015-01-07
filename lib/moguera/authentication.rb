require 'moguera/authentication/version'
require 'moguera/authentication/request'
require 'moguera/authentication/exception'

module Moguera
  class Authentication
    attr_accessor :allow_time_interval

    def initialize(request_token = nil)
      raise RequestTokenRequired, 'Missing request token.' unless request_token

      @request_token = request_token
      @allow_time_interval = allow_time_interval || 600
    end

    def authenticate!(&block)
      raise BlockRequired, 'Request token required.' unless block_given?

      access_key = extract_access_key_from_token(token: @request_token)
      server_request = block.call(access_key)

      validate_token!(server_token: server_request.token, request_token: @request_token)
      validate_time!(request_time: server_request.http_date)

      server_request
    rescue AuthenticationError => e
      authentication_error = AuthenticationError.new(e.message)
      authentication_error.request_token = @request_token
      authentication_error.server_request = server_request if server_request
      raise authentication_error
    end

    def authenticate(&block)
      authenticate!(&block)

    rescue AuthenticationError
      false
    end

    private

    def extract_access_key_from_token(token:)
      begin
        _, access_key_signature = token.split
        access_key, _ = access_key_signature.split(':')
      rescue
        raise AuthenticationError, 'Invalid token.'
      end

      access_key
    end

    def validate_token!(server_token:, request_token:)
      unless server_token == request_token
        raise AuthenticationError, 'Mismatch token.'
      end

      true
    end

    def validate_time!(request_time:)
      return true if @allow_time_interval.nil?

      if @allow_time_interval <= 0
        raise ParameterInvalid, 'Please input a positive value.'
      end

      rt = Time.parse(request_time).to_i
      interval = (Time.now.to_i - rt).abs

      if @allow_time_interval <= interval
        raise AuthenticationError, 'Expired request.'
      end

      true
    end
  end
end
