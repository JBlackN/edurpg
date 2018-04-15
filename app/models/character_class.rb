class CharacterClass < ApplicationRecord
  has_many :specializations, dependent: :destroy
  has_one :talent_tree
  has_many :quests
end
