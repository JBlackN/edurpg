require 'base64'
require 'rest-client'

# Application controller
#
# Contains methods for other controllers.
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user

  # Force relogin when token expired
  rescue_from RestClient::Unauthorized do
    redirect_to :logout
  end

  # Prevent unauthorized users from accessing the application.
  def authorize
    redirect_to :login unless user_signed_in?
  end

  # Prevent users from editing other users' consents.
  #
  # === Parameters
  #
  # [+id+ :: Integer] Consent ID.
  def authorize_consent_edit(id)
    unless current_user.consents.exists?(id.to_i)
      redirect_back fallback_location: root_path
    end
  end

  # Authorize user.
  def authorize_user
    redirect_to :login unless current_user.permission.use_app
  end

  # Prevent users from editing other users' talent trees.
  #
  # === Parameters
  #
  # [+id+ :: Integer] Talent tree ID.
  def authorize_user_manage_talent_tree(id)
    unless current_user.character.talent_trees.exists?(id.to_i)
      redirect_to user_talent_trees_path
    end
  end

  # Prevent users from editing other users' talents.
  #
  # === Parameters
  #
  # [+id+ :: Integer] Talent tree's talent ID.
  def authorize_user_manage_talent_tree_talent(id)
    unless current_user.character.talent_trees.exists?(
        TalentTreeTalent.find(id).talent_tree.id)
      redirect_to user_talent_trees_path
    end
  end

  # Only enable admins to access admin interface.
  def authorize_admin
    redirect_to :login unless current_user.permission.manage_app ||
      current_user.permission.manage_attrs ||
      current_user.permission.manage_achievement_categories ||
      current_user.permission.manage_talent_trees ||
      current_user.permission.manage_talents ||
      current_user.permission.manage_quests ||
      current_user.permission.manage_skills ||
      current_user.permission.manage_achievements ||
      current_user.permission.manage_items ||
      current_user.permission.manage_titles
  end

  # Check whether admin is allowed to manage users.
  def authorize_admin_manage_users
    unless current_user.permission.manage_users
      redirect_back fallback_location: root_path
    end
  end

  # Check whether admin is allowed to manage attributes.
  def authorize_admin_manage_attrs
    unless current_user.permission.manage_attrs
      redirect_back fallback_location: root_path
    end
  end

  # Check whether admin is allowed to manage given achievement category. Uses
  # course restrictions.
  #
  # === Parameters
  #
  # [+category_id+ :: Integer] Achievement category ID (default: _nil_).
  def authorize_admin_manage_achievement_categories(category_id = nil)
    if current_user.permission.manage_achievement_categories
      unless category_id.nil?
        if current_user.permission.class_restrictions.any?
          code = AchievementCategory.find(category_id).code
          unless code.nil?
            unless current_user.permission.class_restrictions.exists?(code: code)
              redirect_back fallback_location: root_path
            end
          end
        end
      end
    else
      redirect_back fallback_location: root_path
    end
  end

  # Check whether admin is allowed to manage attributes.
  def authorize_admin_manage_talent_trees
    unless current_user.permission.manage_talent_trees
      redirect_back fallback_location: root_path
    end
  end

  # Check whether admin is allowed to manage given talent tree's talent.
  # Uses course restrictions.
  #
  # === Parameters
  #
  # [+talent_tree_talent_id+ :: Integer] TalentTreeTalent ID (default: _nil_).
  def authorize_admin_manage_talents(talent_tree_talent_id = nil)
    if current_user.permission.manage_talents
      unless talent_tree_talent_id.nil?
        if current_user.permission.class_restrictions.any?
          code = TalentTreeTalent.find(talent_tree_talent_id).talent.code
          unless current_user.permission.class_restrictions.exists?(code: code)
            redirect_back fallback_location: root_path
          end
        end
      end
    else
      redirect_back fallback_location: root_path
    end
  end

  # Check whether admin is allowed to manage quests.
  def authorize_admin_manage_quests
    unless current_user.permission.manage_quests
      redirect_back fallback_location: root_path
    end
  end

  # Check whether admin is allowed to manage skills.
  def authorize_admin_manage_skills
    unless current_user.permission.manage_skills
      redirect_back fallback_location: root_path
    end
  end

  # Check whether admin is allowed to manage achievements.
  def authorize_admin_manage_achievements
    unless current_user.permission.manage_achievements
      redirect_back fallback_location: root_path
    end
  end

  # Check whether admin is allowed to manage items.
  def authorize_admin_manage_items
    unless current_user.permission.manage_items
      redirect_back fallback_location: root_path
    end
  end

  # Check whether admin is allowed to manage titles.
  def authorize_admin_manage_titles
    unless current_user.permission.manage_titles
      redirect_back fallback_location: root_path
    end
  end

  # Gets current User.
  #
  # === Return
  #
  # [User] User currently logged in.
  def current_user
    @current_user ||= User.find_by(
      username: session[:user]['name']) unless session[:user].nil?
  end

  # Checks whether user is signed in.
  def user_signed_in?
    !!current_user
  end

  # Encodes image data to Base64. Adds 'data:image/+type+;base64,' prefix.
  # Filters out forbidden data types (only JPEG, PNG, GIF allowed).
  #
  # === Parameters
  #
  # [+data+ :: ActionDispatch::Http::UploadedFile] Uploaded file (meta)data.
  #
  # === Return
  #
  # [String] Base64 encoded image with 'data:image/+type+;base64,' prefix.
  def img_encode_base64(data)
    content_type = data.content_type.split('/')
    return nil unless content_type[0] == 'image' &&
                      ['jpeg', 'png', 'gif'].include?(content_type[1])

    "data:image/#{content_type[1]};base64, #{Base64.encode64(data.read)}"
  end

  # Sends photo consent e-mail message using UserMailer.
  #
  # === Return
  #
  # [TrueClass|FalseClass] E-mail successfully sent?
  def send_photo_consent_mail
    UserMailer.with(user: current_user).consent_email.deliver_now!
    return true
  rescue Exception
    return false
  end
end
