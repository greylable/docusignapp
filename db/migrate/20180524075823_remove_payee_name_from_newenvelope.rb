class RemovePayeeNameFromNewenvelope < ActiveRecord::Migration[5.2]
  def change
    remove_column :newenvelopes, :payee_name, :string
  end
end
