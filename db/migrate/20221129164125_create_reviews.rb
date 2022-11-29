class CreateReviews < ActiveRecord::Migration[7.0]
  def change
    create_table :reviews do |t|
      t.string :user, null: false
      t.string :show, null: false
      t.integer :rating, null: false
      t.string :amount_watched
      t.string :highlighted_points
      t.string :overall_review
      t.string :referral_id 
      t.timestamps
    end
  end
end
