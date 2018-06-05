class ChangeResendenvRental < ActiveRecord::Migration[5.2]
  def change
    change_column :resendenvs, :rental, :string
  end
end
