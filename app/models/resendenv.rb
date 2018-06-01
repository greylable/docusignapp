class Resendenv < ApplicationRecord
  belongs_to :user, required: true
  require 'csv'
end
