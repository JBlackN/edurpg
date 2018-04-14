class Quest < ApplicationRecord
  belongs_to :character
  belongs_to :character_class, optional: true
  belongs_to :specialization, optional: true
  belongs_to :talent, optional: true
end
