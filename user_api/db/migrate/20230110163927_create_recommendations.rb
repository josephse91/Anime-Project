class CreateRecommendations < ActiveRecord::Migration[7.0]
  def change
    create_table :recommendations do |t|
      t.string :user_id, null: false, index: true
      t.string :show, null: false
      t.string :referral_id, null: false, index: true
      t.boolean :accepted, default: false
      
      t.timestamps
    end
  end
end
