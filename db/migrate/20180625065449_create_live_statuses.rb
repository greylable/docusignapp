class CreateLiveStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :live_statuses do |t|
      t.string :envelope_id
      t.string :rental
      t.string :email
      t.string :name
      t.string :nric
      t.string :mailing_address
      t.string :driver_phone_no
      t.string :birthday
      t.string :pickup_date
      t.string :vehicle_make
      t.string :vehicle_model
      t.string :vehicle_colour
      t.string :licence_plate
      t.string :master_rate
      t.string :weekly_rate
      t.string :min_rental_period
      t.string :deposit
      t.string :accesscode
      t.string :note
      t.string :status
      t.string :email_blurb

      t.timestamps
    end
  end
end
