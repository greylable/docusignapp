class RemoveEmergencyMailingAddressFromNewenvelope < ActiveRecord::Migration[5.2]
  def change
    remove_column :newenvelopes, :emergency_mailing_address, :string
  end
end
