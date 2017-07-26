Rails.application.routes.draw do
  root to: "home#index"

  get 'preview_proxy', to: 'home#preview_proxy'
end
