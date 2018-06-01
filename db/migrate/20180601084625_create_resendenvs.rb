class CreateResendenvs < ActiveRecord::Migration[5.2]
  def change
    create_table :resendenvs do |t|
      t.string :envelope_id
      t.integer :rental
      t.string :email
      t.string :name
      t.string :nric
      t.string :mailing_address
      t.string :driver_phone_no
      t.date :birthday
      t.date :pickup_date
      t.string :vehicle_make
      t.string :vehicle_model
      t.string :vehicle_colour
      t.string :licence_plate
      t.string :master_rate
      t.float :weekly_rate
      t.string :min_rental_period
      t.integer :deposit
      t.string :accesscode
      t.string :note

      t.timestamps
    end
  end
end
