class Talent < ApplicationRecord
  has_and_belongs_to_many :specializations
  has_many :quests
  has_many :talent_attributes, dependent: :destroy
  has_many :character_attributes, through: :talent_attributes
  has_many :talent_tree_talents
  has_many :talent_trees, through: :talent_tree_talents
end
