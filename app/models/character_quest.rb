# Character's completed quest model
class CharacterQuest < ApplicationRecord
  belongs_to :character
  belongs_to :quest
end
