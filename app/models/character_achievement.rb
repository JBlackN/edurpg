class CharacterAchievement < ApplicationRecord
  belongs_to :character
  belongs_to :achievement
end
