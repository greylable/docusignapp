class Voidenvelope < ApplicationRecord
  # has_attached_file :attachment
  belongs_to :user, required: true
  require 'csv'

  def self.import(file, user)
    CSV.foreach(file.path, headers:true) do |row|
      puts row[0]
      # puts Voidenvelope.errors.full_messages
      v = Voidenvelope.create(envelope_id: row[0], name: row[1], void_reason: row[2], user: user)
      # v.save!

      # t.string "name"
      # t.string "envelope_id"
      # t.string "void_reason"
      # t.integer "user_id"
    end
  end
end
