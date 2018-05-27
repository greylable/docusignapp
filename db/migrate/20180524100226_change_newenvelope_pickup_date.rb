class ChangeNewenvelopePickupDate < ActiveRecord::Migration[5.2]
  def change
    change_column :newenvelopes, :pickup_date, :date
  end
end
