class RemoveEmergencyEmailFromNewenvelope < ActiveRecord::Migration[5.2]
  def change
    remove_column :newenvelopes, :emergency_email, :string
  end
end
