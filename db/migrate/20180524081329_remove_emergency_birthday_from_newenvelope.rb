class RemoveEmergencyBirthdayFromNewenvelope < ActiveRecord::Migration[5.2]
  def change
    remove_column :newenvelopes, :emergency_birthday, :datetime
  end
end
