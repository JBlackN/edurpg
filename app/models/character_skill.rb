# Character's skill model
class CharacterSkill < ApplicationRecord
  belongs_to :character
  belongs_to :skill
end
