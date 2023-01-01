class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :username, null: false, index: true
      t.string :password_digest, null: false
      t.json :rooms, default: {}
      t.json :peers, default: {}
      t.json :requests, default: {"room"=>{}, "peer"=>{}, "roomAuth"=>{}}
      t.string :genre_preference
      t.string :go_to_motto
      t.text :user_grade_protocol
      t.string :session_token

      t.timestamps
    end
  end
end
