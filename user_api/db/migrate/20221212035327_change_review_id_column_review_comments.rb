class ChangeReviewIdColumnReviewComments < ActiveRecord::Migration[7.0]
  def change
    change_column :review_comments, :review_id, :integer, using: 'review_id::integer'
  end
end
