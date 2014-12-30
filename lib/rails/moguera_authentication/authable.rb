module MogueraAuthentication
  module Authable
    extend ActiveSupport::Concern

    included do
      helper_method :current_user, :user_signed_in?
    end

    def current_user=(user)
      @current_user = user
    end

    def current_user
      @current_user
    end

    def user_signed_in?
      !!current_user
    end

    def require_sign_in!
      validate_user!
      sign_in!(user_class.find_by(find_key => env['moguera.auth'].try(:access_key)))
    end

    def sign_in!(user)
      self.current_user = user
    end

    def sign_out!
      self.current_user = nil
    end

    module ClassMethods
      def require_sign_in!(options={})
        before_filter :require_sign_in!, options
      end
    end

    private

    def user_class
      Rails.application.config.moguera_authentication.user_class
    end

    def find_key
      Rails.application.config.moguera_authentication.find_key
    end

    def validate_user!
      if e = env['moguera.error']
        logger.error "ERROR: #{e.inspect}"
        case e
          when Moguera::Authentication::ParameterInvalid,
               Moguera::Authentication::RequestTokenRequired
            status = 400
            response = {
                code: e.class.to_s,
                message: "#{status} Bad Request: #{e.message}",
                status: status
            }
          when Moguera::Authentication::AuthenticationError
            status = 401
            response = {
                code: e.class.to_s,
                message: "#{status} Unauthorized: #{e.message}",
                status: status
            }
            require 'pp'
            PP.pp ({
                  request_token: e.request_token,
                  server_request_token: e.server_request.token,
                  request_path: e.server_request.request_path,
                  request_method: e.server_request.request_method,
                  http_date: e.server_request.http_date,
                  content_type: e.server_request.content_type
              }), STDERR
          when Moguera::Authentication::UserNotFound
            status = 404
            response = {
                code: e.class.to_s,
                message: "#{status} Not Found: #{e.message}",
                status: status
            }
          else
            status = 500
            response = {
                code: e.class.to_s,
                message: "#{status} Internal Server Error: #{e.message}",
                status: status
            }
        end
        render(json: response, status: status)
      end
    end
  end
end