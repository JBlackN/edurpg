class Item < ApplicationRecord
  has_many :item_attributes, dependent: :destroy
  has_many :character_attributes, through: :item_attributes
  has_one :talent_tree
  has_and_belongs_to_many :quests
  has_and_belongs_to_many :achievements
  has_many :character_items
  has_many :characters, through: :character_items

  default_scope { order(name: :asc) }

  def add_attribute(attribute, points)
    self.item_attributes.build(character_attribute: attribute,
                               points: points)
  end
end
