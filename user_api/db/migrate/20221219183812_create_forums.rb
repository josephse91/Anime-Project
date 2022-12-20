class CreateForums < ActiveRecord::Migration[7.0]
  def change
    create_table :forums do |t|
      t.string :topic, null: false
      t.string :creator, null: false
      t.text :content
      t.string :anime
      t.json :votes, default: {up: 0, down: 0}
      t.string :room

      t.timestamps
    end
  end
end
