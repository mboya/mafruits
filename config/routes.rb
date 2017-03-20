Rails.application.routes.draw do
  root 'home#index'
  # messenger
  match 'messenger/updates', to: 'messenger#verify', as: 'handle_messenger_verification', via: 'get'
  match 'messenger/updates', to: 'messenger#updates', as: 'handle_messenger_updates', via: 'post'

  match 'api/updates', to: 'access#verify', as: 'handle_api_verification', via: 'get'
  match 'api/updates', to: 'access#updates', as: 'handle_api_updates', via: 'post'
end
