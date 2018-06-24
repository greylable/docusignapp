class AddAdminUserToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :admin_user, :boolean
  end
end
