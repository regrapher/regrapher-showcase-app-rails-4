class Post < ActiveRecord::Base
  belongs_to :user

  validates :body, presence: true, length: { maximum: 1000 }

  def can_edit?(some_user)
    some_user == self.user
  end

  def can_destroy?(some_user)
    can_edit?(some_user)
  end
end
