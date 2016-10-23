class AddFeaturedToFunctions < ActiveRecord::Migration[5.0]
  def change
    add_column :functions, :featured, :boolean, default: false
  end
end
