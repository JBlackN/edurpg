class Specialization < ApplicationRecord
  belongs_to :character_class
  has_and_belongs_to_many :talents
end
