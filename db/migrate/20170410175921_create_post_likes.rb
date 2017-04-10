class CreatePostLikes < ActiveRecord::Migration
  def change
    create_table :post_likes do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.references :post, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
    add_index :post_likes, [:user_id, :post_id], unique: true
  end
end
