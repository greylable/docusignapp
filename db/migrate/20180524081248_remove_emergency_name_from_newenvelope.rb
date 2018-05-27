class RemoveEmergencyNameFromNewenvelope < ActiveRecord::Migration[5.2]
  def change
    remove_column :newenvelopes, :emergency_name, :string
  end
end
