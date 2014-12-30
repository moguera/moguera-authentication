module MogueraAuthentication
  class Railtie < ::Rails::Railtie
    config.moguera_authentication = ActiveSupport::OrderedOptions.new
    config.eager_load_namespaces << MogueraAuthentication::Railtie

    initializer 'moguera_authentication.controller_ext' do
      require 'rails/moguera_authentication/authable'
      ActiveSupport.on_load(:action_controller) do
        ActionController::Base.send :include, MogueraAuthentication::Authable
      end
    end

    initializer 'moguera_authentication.set_config' do
      config.moguera_authentication.user_class ||= User rescue nil
      config.moguera_authentication.find_key ||= :access_key
      config.moguera_authentication.secret_access_key ||= :secret_access_key
    end

    generators do
      require 'rails/moguera_authentication/install'
    end
  end
end
