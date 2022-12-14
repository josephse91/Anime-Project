class ChangeOverallReviewColumnReviews < ActiveRecord::Migration[7.0]
  def up
    change_column :reviews, :overall_review, :text, using: 'overall_review::text'
  end
end
