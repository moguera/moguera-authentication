module MogueraAuthentication
  class Install < Rails::Generators::Base
    desc 'Initialize MogueraAuthentication'
    def create_initializer_file
      initializer 'moguera_authentication.rb' do
        <<-FILE.strip_heredoc
          Rails.application.config.middleware.use Rack::MogueraAuthentication do |key|
            secret_key = Rails.application.config.moguera_authentication.user_class
              .find_by(Rails.application.config.moguera_authentication.find_key => key)
              .try(Rails.application.config.moguera_authentication.secret_access_key)

            unless secret_key
              raise Moguera::Authentication::UserNotFound, "access_key: " + key
            end

            secret_key
          end
        FILE
      end
    end
  end
end
