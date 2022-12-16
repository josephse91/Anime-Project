class CreateRooms < ActiveRecord::Migration[7.0]
  def up
    create_table :rooms do |t|

      t.string :room_name, null: false
      t.json :users, default: {}
      t.json :pending_approval, default: {}
      t.json :admin, default: {group_admin: "false", admin_users: {}}

      t.timestamps
    end
  end
end
