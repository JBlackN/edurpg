class TalentTree < ApplicationRecord
  belongs_to :character_class
  belongs_to :specialization
  belongs_to :item, optional: true
  has_many :talent_tree_talents
  has_many :talents, through: :talent_tree_talents
end
