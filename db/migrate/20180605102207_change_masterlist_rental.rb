class ChangeMasterlistRental < ActiveRecord::Migration[5.2]
  def change
    change_column :masterlists, :rental, :string
  end
end
