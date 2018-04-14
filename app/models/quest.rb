class Quest < ApplicationRecord
  belongs_to :character
  belongs_to :character_class, optional: true
  belongs_to :specialization, optional: true
  belongs_to :talent, optional: true
  has_and_belongs_to_many :skills
  has_and_belongs_to_many :achievements
  has_and_belongs_to_many :items
  has_and_belongs_to_many :titles
  has_one :quest_exp_reward, dependent: :destroy

  before_destroy { skills.clear }
  before_destroy { achievements.clear }
  before_destroy { items.clear }
  before_destroy { titles.clear }
end
