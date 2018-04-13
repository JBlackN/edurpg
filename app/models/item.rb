class Item < ApplicationRecord
  has_many :item_attributes
  has_many :character_attributes, through: :item_attributes

  default_scope { order(name: :asc) }
end
