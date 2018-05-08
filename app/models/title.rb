# Title model
class Title < ApplicationRecord
  has_and_belongs_to_many :quests
  has_and_belongs_to_many :achievements

  has_many :character_titles
  has_many :characters, through: :character_titles
end
