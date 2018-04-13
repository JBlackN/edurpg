class CharacterClass < ApplicationRecord
  has_many :specializations, dependent: :destroy
end
