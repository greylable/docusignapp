class IpNewenvelope < ApplicationRecord
  belongs_to :user, required: true
  require 'csv'

  def self.import(file, user)
    CSV.foreach(file.path, headers:true) do |row|
      IpNewenvelope.create(ip_email: row[1], nric: row[2], ip_name: row[3], driver_phone_no: row[4],
                            licence_plate: row[5], min_rental_period: row[6], name_of_bank: row[7],
                            bank_account_no: row[8], emergency_name: row[9], emergency_phone_no: row[10],
                            vehicle_make: row[11], vehicle_model: row[12], pickup_date: row[13], user: user)
    end
  end
end


