class Profile < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :user
  belongs_to :organization

  has_many :degreeholderships, inverse_of: :profile
  has_many :degrees, through: :degreeholderships, dependent: :destroy
end
