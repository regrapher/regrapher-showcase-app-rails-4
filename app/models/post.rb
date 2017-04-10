class Post < ActiveRecord::Base
  belongs_to :user
  has_many :post_likes, dependent: :destroy
  has_many :likers, source: :user, through: :post_likes

  validates :body, presence: true, length: { maximum: 1000 }

  def can_edit?(some_user)
    some_user == self.user
  end

  def can_destroy?(some_user)
    can_edit?(some_user)
  end

  def liked_by?(some_user)
    likers.where(id: some_user.id).exists?
  end
end
