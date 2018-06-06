class AddStatusToResendenv < ActiveRecord::Migration[5.2]
  def change
    add_column :resendenvs, :status, :string
  end
end
