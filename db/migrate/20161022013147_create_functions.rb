class CreateFunctions < ActiveRecord::Migration[5.0]
  def change
    create_table :functions do |t|
      t.text :name, null: false, limit: 100
      t.text :description, limit: 500
      t.string :remote_id, unique: true, null: false
      t.string :runtime, null: false
      t.text :code, null: false, limit: 5000 # arbitrary
      t.integer :memory_size, null: false
      t.integer :timeout, null: false
      t.timestamps null: false
    end
  end
end
