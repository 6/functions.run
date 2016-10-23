class AddUserIdToFunctions < ActiveRecord::Migration[5.0]
  def change
    add_column :functions, :user_id, :integer, null: false
    add_column :users, :api_key, :string, null: false

    add_index :functions, :user_id
    add_index :users, :api_key, unique: true
    add_index :users, :username, unique: true
    add_index :functions, :remote_id, unique: true
    add_index :functions, [:user_id, :name], unique: true
  end
end
