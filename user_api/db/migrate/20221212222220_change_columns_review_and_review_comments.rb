class ChangeColumnsReviewAndReviewComments < ActiveRecord::Migration[7.0]
  def up
    add_column :review_comments, :likes, :integer, default: 0
    add_column :reviews, :likes, :integer, default: 0
  end
end
