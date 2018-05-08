# Talent model
class Talent < ApplicationRecord
  has_and_belongs_to_many :specializations
  has_many :quests
  has_many :talent_attributes, dependent: :destroy
  has_many :character_attributes, through: :talent_attributes
  has_many :talent_tree_talents
  has_many :talent_trees, through: :talent_tree_talents

  # Add attribute to talent.
  #
  # === Parameters
  #
  # [+attribute+ :: CharacterAttribute] Attribute to add.
  # [+points+ :: Integer] Points to set.
  def add_attribute(attribute, points)
    self.talent_attributes.build(character_attribute: attribute,
                                 points: points)
  end
end
