class Specialization < ApplicationRecord
  belongs_to :character_class
  has_one :item
  has_one :talent_tree
  has_and_belongs_to_many :talents
  has_many :quests
  has_many :characters

  before_destroy { talents.clear }
end
