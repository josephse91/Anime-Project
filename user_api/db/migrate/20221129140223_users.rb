class Users < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :username, :string, null: false, unique: true 
    add_column :users, :password_digest, :string, null: false
    add_column :users, :genre_preference, :string
    add_column :users, :go_to_motto, :string
    add_column :users, :user_grade_protocol, :string
    add_column :users, :rooms, :text, array: true, default: []
    add_column :users, :peers, :text, array: true, default: []
    add_column :users, :requests, :json

    add_index :users, :username

  end
end
