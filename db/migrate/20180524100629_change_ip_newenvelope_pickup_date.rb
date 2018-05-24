class ChangeIpNewenvelopePickupDate < ActiveRecord::Migration[5.2]
  def change
    change_column :ip_newenvelopes, :pickup_date, :date
  end
end
