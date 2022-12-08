class ChangeColumnUsers2 < ActiveRecord::Migration[7.0]
  def change
    change_column_default(:users, :rooms, from: nil, to: {})
    change_column_default(:users, :peers, from: nil, to: {})
  end
end
