class Character < ApplicationRecord
  belongs_to :user
  has_many :quests

  def init(token)
    info = Usermap.get_info(user.username, token)

    self.name = user.consents.first.name ? info[:name] : 'Anonymous'
    self.image = user.consents.first.photo ? info[:photo] : nil

    if user.permission.use_app
      # TODO: health, experience, level
    end

    save
  end
end
