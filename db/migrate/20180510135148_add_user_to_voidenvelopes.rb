class AddUserToVoidenvelopes < ActiveRecord::Migration[5.2]
  def change
    add_reference :voidenvelopes, :user, foreign_key: true
  end
end
