class RemoveBankAddressFromNewenvelope < ActiveRecord::Migration[5.2]
  def change
    remove_column :newenvelopes, :bank_address, :string
  end
end
