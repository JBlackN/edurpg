class Character < ApplicationRecord
  belongs_to :user
  belongs_to :character_class, optional: true
  belongs_to :specialization, optional: true

  has_many :quests, dependent: :nullify
  has_many :talent_trees, dependent: :destroy

  has_many :character_character_attributes, dependent: :destroy
  has_many :character_attributes, through: :character_character_attributes

  has_many :character_skills, dependent: :destroy
  has_many :skills, through: :character_skills

  has_many :character_achievements, dependent: :destroy
  has_many :achievements, through: :character_achievements

  has_many :character_titles, dependent: :destroy
  has_many :titles, through: :character_titles

  has_many :character_items, dependent: :destroy
  has_many :items, through: :character_items

  has_many :character_quests, dependent: :destroy
  has_many :completed_quests, through: :character_quests, source: :quest

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

  def name_with_titles
    titles_before = []
    titles_after = []

    self.character_titles.each do |title|
      next unless title.active

      if title.title.after_name
        titles_after << title.title.title
      else
        titles_before << title.title.title
      end
    end

    titles_before.join(' ') +
      " #{self.name}#{titles_after.empty? ? '' : ', '}" +
      titles_after.join(', ')
  end

  def achi_points
    points = 0
    self.achievements.each do |achi|
      points += achi.points
    end
    points
  end
end
