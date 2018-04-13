class ItemAttribute < ApplicationRecord
  belongs_to :item
  belongs_to :character_attribute
end
