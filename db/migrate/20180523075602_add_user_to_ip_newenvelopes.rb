class AddUserToIpNewenvelopes < ActiveRecord::Migration[5.2]
  def change
    add_reference :ip_newenvelopes, :user, foreign_key: true
  end
end
