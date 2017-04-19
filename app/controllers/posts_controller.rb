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
             end.limit(1000).order(id: :desc)
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
    render js: <<-JAVASCRIPT
      $('#post-#{params[:id]}').remove();
    JAVASCRIPT
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
end