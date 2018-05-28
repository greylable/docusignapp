class Masterlist < ApplicationRecord
  belongs_to :user, required: true
end
