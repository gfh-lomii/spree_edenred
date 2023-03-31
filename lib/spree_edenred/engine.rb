module SpreeEdenred
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_edenred'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    initializer 'spree_edenred.environment', before: :load_config_initializers do |_app|
      SpreeEdenred::Config = SpreeEdenred::Configuration.new
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare(&method(:activate).to_proc)

    initializer "spree.edenred.payment_methods",
                after: "spree.register.payment_methods" do |app|
      app.config.spree.payment_methods << Spree::PaymentMethod::Edenred
      app.config.assets.precompile += %w(edenred_logo.png)
    end
    initializer "spree.edenred_junaeb.payment_methods",
                after: "spree.register.payment_methods" do |app|
      app.config.spree.payment_methods << Spree::PaymentMethod::EdenredJunaeb
      app.config.assets.precompile += %w(edenred_juaneb_logo.png)
    end
  end
end
