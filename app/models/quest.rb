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
end
