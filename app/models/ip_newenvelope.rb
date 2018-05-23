class IpNewenvelope < ApplicationRecord
  belongs_to :user, required: true
  require 'csv'

  def self.import(file, user)
    CSV.foreach(file.path, headers:true) do |row|
      Ip_newenvelope.create(envelope_id: row[0], name: row[1], void_reason: row[2], user: user)
    end
  end
end
