class AddEmailBlurbToResendenv < ActiveRecord::Migration[5.2]
  def change
    add_column :resendenvs, :email_blurb, :string
  end
end
