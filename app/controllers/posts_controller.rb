class PostsController < ApplicationController
  before_action :set_post, only: [:edit, :update, :destroy]
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @user  = User.find(params[:user_id]) if params[:user_id].present?
    @posts = (@user ? @user.posts : Post.all).order(id: :desc)
  end

  def like
    current_user.post_likes.find_or_create_by(post_id: params[:id])
    redirect_to(:back)
  end

  def dislike
    current_user.post_likes.where(post_id: params[:id]).destroy_all
    redirect_to(:back)
  end

  def new
    @post = current_user.posts.build
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      flash.notice = 'Post saved successfully'
      redirect_to posts_path
    else
      render :new
    end
  end

  def edit
  end

  def show
    @post = Post.find(params[:id])
  end

  def update
    if @post.update(post_params)
      flash.notice = 'Post updated successfully'
      redirect_to post_path(@post)
    else
      render :edit
    end
  end

  def destroy
    @post.destroy
    redirect_to(:back)
  end

  private

  def set_post
    @post = current_user.posts.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:body)
  end
end