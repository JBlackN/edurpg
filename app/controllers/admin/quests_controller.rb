class Admin::QuestsController < ApplicationController
  before_action :authorize_admin_manage_quests, except: [:index]
  before_action :authorize_admin, only: [:index]

  def index
    @quests = Quest.all
  end

  def new
    @quests = Quest.all
    @difficulties = difficulties
    @talents = talents_with_class_restrictions
  end

  def edit
    @quest = Quest.find(params[:id])
    @quests = Quest.all - [@quest]
    @difficulties = difficulties
    @talents = talents_with_class_restrictions
  end

  def create
    @quest = Quest.new(quest_params)

    # Asign class
    unless params[:quest][:character_class].empty?
      @quest.character_class_id = params[:quest][:character_class].to_i
    end

    # Assign spec
    unless params[:quest][:specialization].empty?
      @quest.specialization_id = params[:quest][:specialization].to_i
    end

    # Assign talent
    unless params[:quest][:talent].empty?
      if current_user.permission.class_restrictions.any?
        code = Talent.find(params[:quest][:talent].to_i).code
        unless code.nil?
          unless current_user.permission.class_restrictions.exists?(code: code)
            redirect_back fallback_location: root_path
            return
          end
        end
      end

      @quest.talent_id = params[:quest][:talent].to_i
    end

    # Assign character (quest submitter)
    @quest.character_id = current_user.character.id

    if @quest.save
      redirect_to admin_quests_path
    else
      render 'new' # TODO: errors -> view
    end
  end

  def update
    @quest = Quest.find(params[:id])

    # Asign class
    if params[:quest][:character_class].empty?
      @quest.character_class_id = nil
    else
      @quest.character_class_id = params[:quest][:character_class].to_i
    end

    # Assign spec
    if params[:quest][:specialization].empty?
      @quest.specialization_id = nil
    else
      @quest.specialization_id = params[:quest][:specialization].to_i
    end

    # Assign talent
    if params[:quest][:talent].empty?
      @quest.talent_id = nil
    else
      if current_user.permission.class_restrictions.any?
        code = Talent.find(params[:quest][:talent].to_i).code
        unless code.nil?
          unless current_user.permission.class_restrictions.exists?(code: code)
            redirect_back fallback_location: root_path
            return
          end
        end
      end

      @quest.talent_id = params[:quest][:talent].to_i
    end

    # Reassign character (quest submitter)
    @quest.character_id = current_user.character.id

    if @quest.save && @quest.update(quest_params)
      redirect_to admin_quests_path
    else
      render 'edit' # TODO: errors -> view
    end
  end

  def destroy
    @quest = Quest.find(params[:id])
    @quest.destroy

    redirect_to admin_quests_path
  end

  private

  def quest_params
    params.require(:quest).permit(:name, :difficulty, :objectives, :description,
                                  :deadline, :completion_check_id)
  end

  def difficulties
    [
      ['Velmi jednoduchý', 'very_easy'],
      ['Jednoduchý', 'easy'],
      ['Středně obtížný', 'medium'],
      ['Obtížný', 'hard'],
      ['Velmi obtížný', 'very_hard']
    ]
  end

  def talents_with_class_restrictions
    if current_user.permission.class_restrictions.any?
      codes = current_user.permission.class_restrictions.map do |cr|
        cr.code
      end
      Talent.where(code: codes)
    else
      Talent.all
    end.order(name: :asc).map do |t|
      ["#{t.name} (#{t.code})", t.id]
    end
  end
end
