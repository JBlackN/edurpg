class Achievement < ApplicationRecord
  belongs_to :achievement_category
  has_and_belongs_to_many :quests
end
