# Character's title model
class CharacterTitle < ApplicationRecord
  belongs_to :character
  belongs_to :title
end
