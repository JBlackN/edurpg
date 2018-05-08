# Item model
class Item < ApplicationRecord
  belongs_to :character_class, optional: true
  belongs_to :specialization, optional: true
  has_many :item_attributes, dependent: :destroy
  has_many :character_attributes, through: :item_attributes
  has_many :talent_trees
  has_and_belongs_to_many :quests
  has_and_belongs_to_many :achievements
  has_many :character_items
  has_many :characters, through: :character_items

  default_scope { order(name: :asc) }

  # Add attribute to item.
  #
  # === Parameters
  #
  # [+attribute+ :: CharacterAttribute] Attribute to add.
  # [+points+ :: Integer] Points to set.
  def add_attribute(attribute, points)
    self.item_attributes.build(character_attribute: attribute,
                               points: points)
  end
end
