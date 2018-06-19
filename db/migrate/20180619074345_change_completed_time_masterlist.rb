class ChangeCompletedTimeMasterlist < ActiveRecord::Migration[5.2]
  def change
    change_column :masterlists, :completed_time, :string
  end
end
