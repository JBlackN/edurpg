class Character < ApplicationRecord
  belongs_to :user
  belongs_to :character_class
  belongs_to :specialization

  has_many :quests, dependent: :nullify

  has_many :character_titles
  has_many :titles, through: :character_titles

  def init(token)
    info = Usermap.get_info(user.username, token)

    self.name = user.consents.first.name ? info[:name] : 'Anonymous'
    self.image = user.consents.first.photo ? info[:photo] : nil

    if user.permission.use_app
      # TODO: health, experience, level
    end

    save
  end

  def add_title(title, active = false)
    self.character_titles.build(title: title, active: active)
  end
end
