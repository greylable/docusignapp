class RemoveNameOfBankFromNewenvelope < ActiveRecord::Migration[5.2]
  def change
    remove_column :newenvelopes, :name_of_bank, :string
  end
end
