class AddUserToResendenv < ActiveRecord::Migration[5.2]
  def change
    add_reference :resendenvs, :user, foreign_key: true
  end
end
