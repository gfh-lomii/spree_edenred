Spree::Core::Engine.routes.draw do
  get '/edenred/login', to: 'edenred#login'
  get '/edenred/logout', to: 'edenred#logout'

  namespace :api, path: 'api' do
    namespace :v2 do
      namespace :storefront do
        namespace :account do
          get 'pay_with_edenred', to: 'edenred#pay_with_edenred', as: :pay_with_edenred
        end
      end
    end
  end
end
