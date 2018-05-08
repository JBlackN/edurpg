# Class restriction (= by course) model for permissions
class ClassRestriction < ApplicationRecord
  belongs_to :permission
end
