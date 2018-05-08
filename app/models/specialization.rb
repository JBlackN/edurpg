# CharacterClass's specialization model
class Specialization < ApplicationRecord
  belongs_to :character_class
  has_one :item
  has_many :talent_trees
  has_and_belongs_to_many :talents
  has_many :quests
  has_many :characters

  before_destroy { talents.clear }
end
