class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # devise :database_authenticatable, :registerable,
  #        :recoverable, :rememberable, :trackable, :validatable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :voidenvelopes
  has_many :newenvelopes
  has_many :ip_newenvelopes
  has_many :masterlists
  has_many :resendenvs
  has_many :live_status
end
