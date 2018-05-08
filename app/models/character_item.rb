# Character's item model
class CharacterItem < ApplicationRecord
  belongs_to :character
  belongs_to :item
end
