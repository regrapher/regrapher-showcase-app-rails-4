class Post < ActiveRecord::Base
  belongs_to :user
  has_many :post_likes, inverse_of: :post, dependent: :destroy
  has_many :likers, source: :user, through: :post_likes

  validates :body, presence: true, length: { maximum: 1000 }

  scope :timeline, -> (viewer_user, poster_user) do
    timeline = viewer_user ? Post.select(<<-SQL) : Post.select('posts.*, false as liked')
      posts.*, exists (select 1 from post_likes where post_likes.user_id=#{viewer_user.id.to_i} 
            and post_likes.post_id=posts.id) as liked
    SQL
    if poster_user
      timeline.where(user: poster_user)
    else
      timeline.includes(:user)
    end.limit(1000).order(id: :desc)
  end

  def can_edit?(some_user)
    some_user && (some_user == self.user)
  end

  def can_destroy?(some_user)
    can_edit?(some_user)
  end
end
