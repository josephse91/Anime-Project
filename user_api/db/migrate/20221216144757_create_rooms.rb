class CreateRooms < ActiveRecord::Migration[7.0]
  def up
    create_table :rooms do |t|
      t.string :room_name, null: false, index: true
      t.json :users, default: {}
      t.boolean :private, default: true
      t.json :pending_approval, default: {}
      t.json :admin, default: {group_admin: true, admin_users: {}}
      t.json :entry_keys, default: {}

      t.timestamps
    end
  end
end
