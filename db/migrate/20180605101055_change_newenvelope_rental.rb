class ChangeNewenvelopeRental < ActiveRecord::Migration[5.2]
  def change
    change_column :newenvelopes, :rental, :string
  end
end
