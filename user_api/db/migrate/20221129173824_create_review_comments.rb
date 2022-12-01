class CreateReviewComments < ActiveRecord::Migration[7.0]
  def change
    create_table :review_comments do |t|
      t.string :comment, null: false
      t.integer :review_id
      t.string :user_id
      t.timestamps
    end
  end
end
