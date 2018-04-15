class Achievement < ApplicationRecord
  belongs_to :achievement_category
  has_and_belongs_to_many :quests
  has_and_belongs_to_many :items
  has_and_belongs_to_many :titles

  before_destroy { items.clear }
  before_destroy { titles.clear }
end
