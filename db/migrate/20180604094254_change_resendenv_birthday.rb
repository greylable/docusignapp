class ChangeResendenvBirthday < ActiveRecord::Migration[5.2]
  def change
    change_column :resendenvs, :birthday, :string
  end
end
