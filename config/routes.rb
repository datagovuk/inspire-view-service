Rails.application.routes.draw do
  root to: "home#index"

  get 'data/map-preview', to: 'home#index'
  get 'data/preview_proxy', to: 'home#preview_proxy'
  get 'data/preview_getinfo', to: 'home#preview_getinfo'
end
