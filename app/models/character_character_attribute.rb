# Character's attribute model
class CharacterCharacterAttribute < ApplicationRecord
  belongs_to :character
  belongs_to :character_attribute
end
