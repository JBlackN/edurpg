class CharacterClass < ApplicationRecord
  has_many :specializations, dependent: :destroy
  has_many :quests
end
