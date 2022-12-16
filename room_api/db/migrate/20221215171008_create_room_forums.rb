class CreateRoomForums < ActiveRecord::Migration[7.0]
  def up
    create_table :room_forums do |t|
      t.string :topic, null: false
      t.text :content
      t.string :anime
      t.json :votes, default: {up: 0, down: 0}
      t.string :user
      t.integer :room_id
      t.boolean :private, default: false

      t.timestamps
    end
  end
end
