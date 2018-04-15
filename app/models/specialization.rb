class Specialization < ApplicationRecord
  belongs_to :character_class
  has_one :talent_tree
  has_and_belongs_to_many :talents
  has_many :quests

  before_destroy { talents.clear }
end
