class AchievementCategory < ApplicationRecord
  has_many :subcategories, class_name: 'AchievementCategory',
                           foreign_key: 'parent_id'
  has_many :achievements, dependent: :destroy

  belongs_to :parent, class_name: 'AchievementCategory'
end
