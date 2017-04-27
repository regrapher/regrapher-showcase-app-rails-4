Rails.application.routes.draw do
  root 'posts#index'

  devise_for :users

  resources :posts do
    resource :post_likes, only: [:create, :destroy]
  end

  resources :users, only: [] do
    resources :posts, only: [:index]
  end

  get 'pages/about', to: 'pages#about', as: :about_page
  post 'pages/about_button', as: :about_button
end
