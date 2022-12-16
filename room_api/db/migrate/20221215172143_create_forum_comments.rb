class CreateForumComments < ActiveRecord::Migration[7.0]
  def up
    create_table :forum_comments do |t|
      t.integer :forum_topic_id
      t.string :comment, null: false
      t.string :creator, null: false
      t.json :votes, default: {up: 0, down: 0}
      t.json :children
      t.integer :level


      t.timestamps
    end
  end
end
