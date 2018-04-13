class CharacterAttribute < ApplicationRecord
  has_many :skills, dependent: :destroy
  has_many :item_attributes, dependent: :destroy
  has_many :items, through: :item_attributes

  default_scope { order(name: :asc) }
end
