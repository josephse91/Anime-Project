class ChangeColumnReviews < ActiveRecord::Migration[7.0]
  def change
    change_column :reviews, :highlighted_points, :text, array: true, using: 'highlighted_points::text[]'
    change_column_default(:reviews, :highlighted_points, from: nil, to: [])
  end
end
