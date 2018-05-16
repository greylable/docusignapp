class AddUserToNewenvelopes < ActiveRecord::Migration[5.2]
  def change
    add_reference :newenvelopes, :user, foreign_key: true
  end
end
