class CreateWatchLaters < ActiveRecord::Migration[7.0]
  def change
    create_table :watch_laters do |t|
      t.string :user_id, null: false, index: true
      t.string :show, null: false
      t.string :referral_id, index: true

      t.timestamps
    end
  end
end
