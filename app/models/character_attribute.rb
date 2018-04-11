class CharacterAttribute < ApplicationRecord
  has_many :skills, dependent: :destroy

  default_scope { order(name: :asc) }
end
