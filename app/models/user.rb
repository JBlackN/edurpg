class User < ApplicationRecord
  has_one :permission
  has_many :consents, -> { order 'created_at DESC' }
  has_one :character

  def consent_invalid?
    return true unless consents.any?
    DateTime.now > consents.first.created_at + 30.days # TODO: -> app settings
  end

  def only_admin?
    !permission.use_app && (
      permission.manage_users ||
      permission.manage_app ||
      permission.manage_attrs ||
      permission.manage_achievement_categories ||
      permission.manage_talent_trees ||
      permission.manage_talents ||
      permission.manage_quests ||
      permission.manage_skills ||
      permission.manage_achievements ||
      permission.manage_items ||
      permission.manage_titles
    )
  end

  def only_user?
    permission.use_app &&
    !permission.manage_users &&
    !permission.manage_app &&
    !permission.manage_attrs &&
    !permission.manage_achievement_categories &&
    !permission.manage_talent_trees &&
    !permission.manage_talents &&
    !permission.manage_quests &&
    !permission.manage_skills &&
    !permission.manage_achievements &&
    !permission.manage_items &&
    !permission.manage_titles
  end
end
