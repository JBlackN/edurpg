class Talent < ApplicationRecord
  has_and_belongs_to_many :specializations
  has_many :quests
end
