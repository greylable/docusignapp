class RemoveBankCodeFromNewenvelope < ActiveRecord::Migration[5.2]
  def change
    remove_column :newenvelopes, :bank_code, :string
  end
end
