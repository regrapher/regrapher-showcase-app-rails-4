Rails.application.routes.draw do
  root 'posts#index'

  devise_for :users

  resources :posts do
    put :like, on: :member
  end

  resources :users, only: [] do
    resources :posts, only: [:index]
  end
end
