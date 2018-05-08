# Achievement category model
class AchievementCategory < ApplicationRecord
  has_many :subcategories, class_name: 'AchievementCategory',
                           foreign_key: 'parent_id', dependent: :destroy
  has_many :achievements, dependent: :destroy
  belongs_to :parent, class_name: 'AchievementCategory', optional: true

  default_scope { order(name: :asc) }
end
