Rails.application.routes.draw do
  root 'posts#index'

  devise_for :users

  resources :posts do
    post :like, on: :member
    delete :like, on: :member, to: 'posts#dislike', as: :dislike
  end

  resources :users, only: [] do
    resources :posts, only: [:index]
  end
end
