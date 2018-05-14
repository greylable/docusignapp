class AddStatusToVoidenvelopes < ActiveRecord::Migration[5.2]
  def change
    add_column :voidenvelopes, :status, :string
  end
end
