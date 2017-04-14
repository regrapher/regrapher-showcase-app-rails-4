class PostsController < ApplicationController
  before_action :set_user_post, only: [:edit, :update, :destroy]
  before_action :set_post, only: [:show]
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @posts = if params[:user_id].present?
               @user = User.find(params[:user_id])
               @user.posts
             else
               Post.all.includes(:user)
             end.order(id: :desc)
  end

  def like
    current_user.like_post(params[:id])
    redirect_to back_with_post_anchor_url(params[:id])
  end

  def dislike
    current_user.dislike_post(params[:id])
    redirect_to back_with_post_anchor_url(params[:id])
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

  def set_user_post
    @post = current_user.posts.find(params[:id])
  end

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:body)
  end

  def back_with_post_anchor_url(post_id)
    u = URI.parse(request.referer)
    u.fragment = "post-#{post_id}" if u.fragment.blank?
    u.to_s
  end
end