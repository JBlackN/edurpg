# Talent's attribute model
class TalentAttribute < ApplicationRecord
  belongs_to :talent
  belongs_to :character_attribute
end
