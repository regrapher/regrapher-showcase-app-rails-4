class PostLikesController < ApplicationController
  def create
    like_post(true)
  end

  def destroy
    like_post(false)
  end

  private

  def like_post(liked)
    current_user.like_post(params[:post_id], liked)
    render js: <<-JAVASCRIPT
        $('#post-#{params[:post_id]}').toggleClass('liked', #{!!liked});
    JAVASCRIPT
  end
end