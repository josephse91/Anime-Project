class ChangeColumnsReviewComments3 < ActiveRecord::Migration[7.0]
  def change
    change_column :review_comments, :comment_type, :integer, using: 'comment_type::integer'
    change_column :review_comments, :parent, :integer, using: 'parent::integer'
  end
end
