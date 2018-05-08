# User model
class User < ApplicationRecord
  has_one :permission, dependent: :destroy
  has_many :consents, -> { order 'created_at DESC' }, dependent: :destroy
  has_one :character, dependent: :destroy
  has_one_time_password

  # Checks whether user's consent is invalid.
  #
  # === Return
  #
  # [TrueClass|FalseClass] Consent invalid?
  def consent_invalid?
    return true unless consents.any?

    # Invalid after 1 month
    DateTime.now > consents.first.created_at + 30.days # TODO: -> app settings
  end

  # Determines whether user is admin.
  #
  # === Return
  #
  # [TrueClass|FalseClass] Is user admin?
  def admin?
    admin_permissions.any?
  end

  # Determines whether user is admin only.
  #
  # === Return
  #
  # [TrueClass|FalseClass] Is user admin only?
  def admin_only?
    !permission.use_app && admin_permissions.any?
  end

  # Determines whether user is admin with all privileges.
  #
  # === Return
  #
  # [TrueClass|FalseClass] Is user admin with all privileges?
  def admin_full?
    !permission.use_app && admin_permissions.all?
  end

  # Determines whether user is both user and admin.
  #
  # === Return
  #
  # [TrueClass|FalseClass] Is user both user and admin?
  def both_user_and_admin?
    permission.use_app && admin_permissions.any?
  end

  # Determines whether user is user.
  #
  # === Return
  #
  # [TrueClass|FalseClass] Is user user?
  def user?
    permission.use_app
  end

  # Determines whether user is user only.
  #
  # === Return
  #
  # [TrueClass|FalseClass] Is user user only?
  def user_only?
    permission.use_app && !admin_permissions.any?
  end

  private

  def admin_permissions
    [
      permission.manage_users, permission.manage_app, permission.manage_attrs,
      permission.manage_achievement_categories, permission.manage_talent_trees,
      permission.manage_talents, permission.manage_quests,
      permission.manage_skills, permission.manage_achievements,
      permission.manage_items, permission.manage_titles
    ]
  end
end
