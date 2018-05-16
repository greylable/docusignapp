class Newenvelope < ApplicationRecord
  belongs_to :user, required: true
end
