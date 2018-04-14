class Skill < ApplicationRecord
  belongs_to :character_attribute
  has_and_belongs_to_many :quests
end
