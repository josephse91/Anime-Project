class ChangeColumnUsers < ActiveRecord::Migration[7.0]
  def change
    change_column_default(:users, :rooms, from: '{}', to: nil)
    change_column :users, :rooms, :json, using: 'rooms::json'
    change_column_default(:users, :peers, from: '{}', to: nil)
    change_column :users, :peers, :json, using: 'peers::json'
    change_column :users, :requests, :json, default: {room: {},peer: {}, roomAuth: {}}
    change_column :users, :user_grade_protocol, :text
  end
end
