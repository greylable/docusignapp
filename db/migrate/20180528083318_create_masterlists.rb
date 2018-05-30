class CreateMasterlists < ActiveRecord::Migration[5.2]
  def change
    create_table :masterlists do |t|
      t.string :envelope_id
      t.datetime :created_time
      t.string :recipient_email
      t.string :status
      t.string :recipient_type
      t.datetime :completed_time
      t.datetime :declined_time
      t.string :declined_reason
      t.string :subject_title
      t.string :auth_status
      t.datetime :auth_timestamp
      t.datetime :delivered_date_time
      t.string :note
      t.string :accesscode
      t.string :recipient_status
      t.integer :rental

      t.timestamps
    end
  end
end
