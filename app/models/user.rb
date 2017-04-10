class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable
  has_many :posts, inverse_of: :user, dependent: :destroy
  has_many :post_likes, dependent: :destroy
  has_many :liked_posts, source: :post, through: :post_likes
  def name
    "Anonymous_#{id}"
  end
end
