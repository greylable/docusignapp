class ChangeIpNewenvelopePickupDate1 < ActiveRecord::Migration[5.2]
  def change
    change_column :ip_newenvelopes, :pickup_date, :string
  end
end
