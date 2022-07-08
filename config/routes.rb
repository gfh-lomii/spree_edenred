Spree::Core::Engine.routes.draw do
  get '/edenred/login', to: 'edenred#login'
  get '/edenred/logout', to: 'edenred#logout'
end
