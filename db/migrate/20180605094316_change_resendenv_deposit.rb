class ChangeResendenvDeposit < ActiveRecord::Migration[5.2]
  def change
    change_column :resendenvs, :deposit, :string
  end
end
