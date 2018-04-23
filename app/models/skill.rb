class Skill < ApplicationRecord
  belongs_to :character_attribute
  has_and_belongs_to_many :quests
  has_many :character_skills
  has_many :characters, through: :character_skills

  default_scope { order(name: :asc, rank: :asc) }
end
