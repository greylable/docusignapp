class RemoveEmergencyNricFromNewenvelope < ActiveRecord::Migration[5.2]
  def change
    remove_column :newenvelopes, :emergency_nric, :string
  end
end
