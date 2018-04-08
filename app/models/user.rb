class User < ApplicationRecord
  has_one :permission
  has_one :consent
end
