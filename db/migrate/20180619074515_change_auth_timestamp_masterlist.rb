class ChangeAuthTimestampMasterlist < ActiveRecord::Migration[5.2]
  def change
    change_column :masterlists, :auth_timestamp, :string
  end
end
