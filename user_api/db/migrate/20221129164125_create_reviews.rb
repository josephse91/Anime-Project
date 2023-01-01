class CreateReviews < ActiveRecord::Migration[7.0]
  def change
    create_table :reviews do |t|
      t.string :user, null: false
      t.string :show, null: false
      t.integer :rating, null: false
      t.string :amount_watched
      t.text :highlighted_points, default: [], array: true
      t.text :overall_review
      t.string :referral_id
      t.integer :watch_priority
      t.integer :likes, default: 0 
      t.timestamps
    end
  end
end
