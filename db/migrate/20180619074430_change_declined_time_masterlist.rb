class ChangeDeclinedTimeMasterlist < ActiveRecord::Migration[5.2]
  def change
    change_column :masterlists, :declined_time, :string
  end
end
