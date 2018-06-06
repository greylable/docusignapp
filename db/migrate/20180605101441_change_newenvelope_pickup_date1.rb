class ChangeNewenvelopePickupDate1 < ActiveRecord::Migration[5.2]
  def change
    change_column :newenvelopes, :pickup_date, :string
  end
end
