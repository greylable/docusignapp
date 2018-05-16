class CreateNewenvelopes < ActiveRecord::Migration[5.2]
  def change
    create_table :newenvelopes do |t|
      t.string :envelope_id
      t.integer :rental
      t.string :email
      t.string :name
      t.string :nric
      t.string :mailing_address
      t.string :driver_phone_no
      t.datetime :birthday
      t.datetime :pickup_date
      t.string :vehicle_make
      t.string :vehicle_model
      t.string :vehicle_colour
      t.string :licence_plate
      t.string :master_rate
      t.float :weekly_rate
      t.string :min_rental_period
      t.integer :deposit
      t.string :payee_name
      t.string :name_of_bank
      t.string :bank_address
      t.string :bank_account_no
      t.string :bank_code
      t.string :branch_code
      t.string :swift_code
      t.string :driver_licence_no
      t.datetime :expiration_date
      t.string :driver_licence_class
      t.string :emergency_name
      t.string :emergency_nric
      t.string :emergency_mailing_address
      t.string :emergency_email
      t.string :emergency_phone_no
      t.datetime :emergency_birthday

      t.timestamps
    end
  end
end
