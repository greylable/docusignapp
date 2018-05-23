class CreateIpNewenvelopes < ActiveRecord::Migration[5.2]
  def change
    create_table :ip_newenvelopes do |t|
      t.string :ip_email
      t.string :nric
      t.string :ip_name
      t.string :driver_phone_no
      t.string :licence_plate
      t.string :min_rental_period
      t.string :name_of_bank
      t.string :bank_account_no
      t.string :emergency_name
      t.string :emergency_phone_no
      t.string :vehicle_make
      t.string :vehicle_model
      t.datetime :pickup_date

      t.timestamps
    end
  end
end
