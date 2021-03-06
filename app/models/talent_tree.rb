# Talent tree model
class TalentTree < ApplicationRecord
  belongs_to :character_class, optional: true
  belongs_to :specialization, optional: true
  belongs_to :item, optional: true
  belongs_to :character, optional: true
  has_many :talent_tree_talents, dependent: :destroy
  has_many :talents, through: :talent_tree_talents

  # Add talent to talent tree.
  #
  # === Parameters
  #
  # [+talent+ :: Talent] Talent to add.
  # [+x+ :: Integer] Position (+x+ coordinate).
  # [+y+ :: Integer] Position (+y+ coordinate).
  def add_talent(talent, x, y)
    self.talent_tree_talents.create(talent: talent, pos_x: x, pos_y: y)
  end
end
