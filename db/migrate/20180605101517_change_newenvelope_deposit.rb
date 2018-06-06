class ChangeNewenvelopeDeposit < ActiveRecord::Migration[5.2]
  def change
    change_column :newenvelopes, :deposit, :string
  end
end
