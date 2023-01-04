class CreateShowRatings < ActiveRecord::Migration[7.0]
  def change
    create_table :show_ratings do |t|
      t.string :show_title, null: false
      t.string :room_id, null: false
      t.json :reviewers, default: {}
      t.integer :total_points, null: false
      t.integer :number_of_reviews

      t.timestamps
    end
  end
end
