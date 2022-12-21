class CreateForumComments < ActiveRecord::Migration[7.0]
  def up
    create_table :forum_comments do |t|
      t.text :comment, null: false
      t.integer :forum_post, null: false
      t.string :comment_owner, null: false
      t.integer :top_comment
      t.integer :level
      t.integer :parent
      t.json :children, default: [], array: true
      t.json :votes, default: {up: 0, down: 0}

      t.timestamps
    end
  end
end
