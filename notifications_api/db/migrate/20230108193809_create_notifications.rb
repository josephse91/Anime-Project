class CreateNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :notifications do |t|
      t.string :event_action, null: false
      t.string :target, null: false
      t.integer :target_id, null: false
      t.string :action_user, null: false
      t.string :recipient, null: false
      t.boolean :seen, default: false
      t.integer :common_actions, default: 0
      t.text :message
      t.boolean :selected, default: true

      t.timestamps
    end
  end
end
