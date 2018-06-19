class ChangeDeliveredDateTimeMasterlist < ActiveRecord::Migration[5.2]
  def change
    change_column :masterlists, :delivered_date_time, :string
  end
end
