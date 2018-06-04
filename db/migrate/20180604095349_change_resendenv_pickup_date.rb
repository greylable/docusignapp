class ChangeResendenvPickupDate < ActiveRecord::Migration[5.2]
  def change
    change_column :resendenvs, :pickup_date, :string
  end
end
