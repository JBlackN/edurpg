class CharacterClass < ApplicationRecord
  has_many :specializations, dependent: :destroy
  has_one :item
  has_many :talent_trees
  has_many :quests
  has_many :characters
end
