Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get "/", to: "login#index"
  get "/login", to: "login#index"
  get "/login/redirect", to: "login#login_redirect"
  get "/callback", to: "login#handle_callback"

  get "/protected", to: "protected_api#index"
end
