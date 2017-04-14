class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable
  has_many :posts, inverse_of: :user, dependent: :destroy
  has_many :post_likes, inverse_of: :post, dependent: :destroy
  has_many :liked_posts, source: :post, through: :post_likes

  def name
    "Anonymous_#{id}"
  end

  def like_post(post_id)
    post_likes.find_or_create_by(post_id: post_id)
  end

  def dislike_post(post_id)
    post_likes.where(post_id: post_id).destroy_all
  end
end
