# Initializer controller
#
# Initializes the application on first admin login.
class Admin::InitializerController < ApplicationController
  before_action :authorize_admin

  def index
    unless CharacterClass.any?
      Initializer.new.init(session[:user]['token'], current_user)
    end
  end

  def show
    render json: if DelayedJob.any?
                   if CharacterClass.any?
                     if Specialization.any?
                       if AchievementCategory.any?
                         if Item.any?
                           if Title.any?
                             :quest
                           else
                             :item
                           end
                         else
                           :achi_cat
                         end
                       else
                         :spec
                       end
                     else
                       :class
                     end
                   else
                     :kos
                   end
                 else
                   :done
                 end
  end
end
