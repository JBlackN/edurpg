class Character < ApplicationRecord
  belongs_to :user
  belongs_to :character_class
  belongs_to :specialization

  has_many :quests, dependent: :nullify

  has_many :character_character_attributes, dependent: :destroy
  has_many :character_attributes, through: :character_character_attributes

  has_many :character_skills
  has_many :skills, through: :character_skills

  has_many :character_titles, dependent: :destroy
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

  def add_attribute(attr, points = 0)
    self.character_character_attributes.build(character_attribute: attr,
                                              points: points)
  end

  def add_title(title, active = false)
    self.character_titles.build(title: title, active: active)
  end
end
