class User < ApplicationRecord
  has_one :permission
  has_many :consents, -> { order 'created_at DESC' }
  has_one :character

  def consent_invalid?
    return true unless consents.any?
    DateTime.now > consents.first.created_at + 30.days # TODO: -> app settings
  end
end
