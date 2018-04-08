class Permission < ApplicationRecord
  belongs_to :user
  has_many :class_restrictions
end
