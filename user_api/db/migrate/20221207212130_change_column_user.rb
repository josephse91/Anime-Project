class ChangeColumnUser < ActiveRecord::Migration[7.0]
  def change
    change_column :users, :rooms, :text
    change_column :users, :peers, :text
  end
end
