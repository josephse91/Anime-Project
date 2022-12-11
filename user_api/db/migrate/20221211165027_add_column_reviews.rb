class AddColumnReviews < ActiveRecord::Migration[7.0]
  def change
    add_column :reviews, :watch_priority, :integer
  end
end
