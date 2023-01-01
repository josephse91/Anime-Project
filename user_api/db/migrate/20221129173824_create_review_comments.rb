class CreateReviewComments < ActiveRecord::Migration[7.0]
  def change
    create_table :review_comments do |t|
      t.text :comment, null: false
      t.integer :review_id, null: false
      t.string :user_id, null: false
      t.integer :top_comment
      t.string :comment_type, null: false
      t.integer :parent, null: false
      t.integer :likes, default: 0
      
      t.timestamps
    end
  end
end
