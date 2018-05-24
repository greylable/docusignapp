class RemoveEmergencyPhoneNoFromNewenvelope < ActiveRecord::Migration[5.2]
  def change
    remove_column :newenvelopes, :emergency_phone_no, :string
  end
end
