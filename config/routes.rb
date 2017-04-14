Rails.application.routes.draw do
  root 'posts#index'

  devise_for :users

  resources :posts do
    post :like, on: :member
    delete :like, on: :member, to: 'posts#dislike', as: :dislike
    post :comments, on: :member, to: 'posts#create_comment'
    get 'comments/:comment_id/edit', on: :member, to: 'posts#index'
    put 'comments/:comment_id', on: :member, to: 'posts#update_comment'
  end

  resources :users, only: [] do
    resources :posts, only: [:index]
  end
end
