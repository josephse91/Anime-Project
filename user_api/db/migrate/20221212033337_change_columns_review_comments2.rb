class ChangeColumnsReviewComments2 < ActiveRecord::Migration[7.0]
  def change
    change_column_null :review_comments, :top_comment, true
  end
end
