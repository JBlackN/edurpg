class CharacterClass < ApplicationRecord
  has_many :specializations, dependent: :destroy
  has_one :item
  has_one :talent_tree
  has_many :quests
  has_many :characters
end
