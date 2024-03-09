class AddIndexPost < ActiveRecord::Migration[7.1]
  def change
    add_index :posts, [:user_id, :created_at]
  end
end
