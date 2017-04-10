class PostsController < ApplicationController
  before_action :set_post, only: [:edit, :update, :destroy]

  def index
    @user = User.find(params[:user_id]) if params[:user_id].present?
    @posts = (@user ? @user.posts : Post.all).order(id: :desc)
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