class ChangeCreatedTimeMasterlist < ActiveRecord::Migration[5.2]
  def change
    change_column :masterlists, :created_time, :string
  end
end
