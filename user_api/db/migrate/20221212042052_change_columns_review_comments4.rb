class ChangeColumnsReviewComments4 < ActiveRecord::Migration[7.0]
  def change
    change_column :review_comments, :comment_type, :string
    change_column :review_comments, :comment, :text, using: 'comment::text'
  end
end
