class Permission < ApplicationRecord
  belongs_to :user
  has_many :class_restrictions, dependent: :destroy

  def assign(all, token)
    assign_init
    return assign_all_and_save if all
    roles = Usermap.get_roles(user.username, token)
    return nil if roles[:teacher].empty? && roles[:student].nil?

    assign_teacher unless roles[:teacher].empty?
    roles[:teacher].each do |role|
      class_restrictions << ClassRestriction.create(code: role['code'],
                                                    code_full: role['code_full'])
    end
    assign_student unless roles[:student].nil?

    save
  end

  def refresh(token)
    return true if user.admin_full?
    class_restrictions.clear
    assign(false, token)
  end

  private

  def assign_init
    self.use_app = false
    self.manage_users = false
    self.manage_app = false
    self.manage_attrs = false
    self.manage_achievement_categories = false
    self.manage_talent_trees = false
    self.manage_talents = false
    self.manage_quests = false
    self.manage_skills = false
    self.manage_achievements = false
    self.manage_items = false
    self.manage_titles = false
  end

  def assign_all_and_save
    self.manage_users = true
    self.manage_app = true
    self.manage_attrs = true
    self.manage_achievement_categories = true
    self.manage_talent_trees = true
    self.manage_talents = true
    self.manage_quests = true
    self.manage_skills = true
    self.manage_achievements = true
    self.manage_items = true
    self.manage_titles = true
    save
  end

  def assign_teacher
    self.manage_talents = true
    self.manage_quests = true
    self.manage_skills = true
    self.manage_achievements = true
    self.manage_items = true
    self.manage_titles = true
  end

  def assign_student
    self.use_app = true
  end
end
