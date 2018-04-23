class Achievement < ApplicationRecord
  belongs_to :achievement_category
  has_and_belongs_to_many :quests
  has_and_belongs_to_many :items
  has_and_belongs_to_many :titles

  has_many :character_achievements
  has_many :characters, through: :character_achievements

  before_destroy { items.clear }
  before_destroy { titles.clear }

  default_scope { order(name: :asc) }
end
