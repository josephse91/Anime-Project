class ChangeColumnsReviewComments < ActiveRecord::Migration[7.0]
  def change
    add_column :review_comments, :top_comment, :integer
    add_column :review_comments, :comment_type, :string, null: false
    add_column :review_comments, :parent, :string, null: false
    change_column :review_comments, :user_id, :string, null: false
    change_column :review_comments, :review_id, :string, null: false
  end
end
