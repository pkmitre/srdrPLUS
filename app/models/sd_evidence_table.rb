# == Schema Information
#
# Table name: sd_evidence_tables
#
#  id               :bigint(8)        not null, primary key
#  name             :text(65535)
#  sd_meta_datum_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class SdEvidenceTable < ApplicationRecord
  belongs_to :sd_meta_datum, inverse_of: :sd_evidence_tables

  has_one_attached :picture

  has_many :sd_outcomes, as: :sd_outcomeable
end
