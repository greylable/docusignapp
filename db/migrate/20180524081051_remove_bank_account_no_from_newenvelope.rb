class RemoveBankAccountNoFromNewenvelope < ActiveRecord::Migration[5.2]
  def change
    remove_column :newenvelopes, :bank_account_no, :string
  end
end
