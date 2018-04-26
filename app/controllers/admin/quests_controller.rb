class Admin::QuestsController < ApplicationController
  before_action :authorize_admin_manage_quests, except: [:index]
  before_action :authorize_admin, only: [:index]

  def index
    @quests = Quest.all
  end

  def new
    @quests = Quest.all
    @difficulties = difficulties
    @groups = quest_groups
  end

  def edit
    @quest = Quest.find(params[:id])
    @quests = Quest.all - [@quest]
    @difficulties = difficulties
    @groups = quest_groups
    @group = if @quest.talent
               "t#{@quest.talent.id}"
             elsif @quest.specialization
               "s#{@quest.specialization.id}"
             elsif @quest.character_class
               "c#{@quest.character_class.id}"
             else
               ''
             end
  end

  def create
    @quest = Quest.new(quest_params)

    if params[:quest].key?(:groups) && !params[:quest][:groups].empty?
      group_id_type = params[:quest][:groups][0]
      group_id = params[:quest][:groups][1..-1].to_i

      # Asign class
      @quest.character_class_id = group_id if group_id_type == 'c'

      # Assign spec
      @quest.specialization_id = group_id if group_id_type == 's'

      # Assign talent
      if group_id_type == 't'
        if current_user.permission.class_restrictions.any?
          code = Talent.find(group_id).code
          unless code.nil?
            unless current_user.permission.class_restrictions.exists?(code: code)
              redirect_back fallback_location: root_path
              return
            end
          end
        end

        @quest.talent_id = group_id
      end
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

    if params[:quest].key?(:groups) && !params[:quest][:groups].empty?
      group_id_type = params[:quest][:groups][0]
      group_id = params[:quest][:groups][1..-1].to_i

      # Asign class
      if group_id_type == 'c'
        @quest.character_class_id = group_id
        @quest.specialization_id = nil
        @quest.talent_id = nil
      end

      # Assign spec
      if group_id_type == 's'
        @quest.character_class_id = nil
        @quest.specialization_id = group_id
        @quest.talent_id = nil
      end

      # Assign talent
      if group_id_type == 't'
        if current_user.permission.class_restrictions.any?
          code = Talent.find(group_id).code
          unless code.nil?
            unless current_user.permission.class_restrictions.exists?(code: code)
              redirect_back fallback_location: root_path
              return
            end
          end
        end

        @quest.character_class_id = nil
        @quest.specialization_id = nil
        @quest.talent_id = group_id
      end
    else
      @quest.character_class_id = nil
      @quest.specialization_id = nil
      @quest.talent_id = nil
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

  def quest_groups
    [
      ['Povolání', CharacterClass.all.map { |c| [c.name, "c#{c.id}"] }],
      ['Specializace', Specialization.all.order(name: :asc).map do |s|
        ["#{s.name} (#{s.character_class.code})", "s#{s.id}"]
      end
      ],
      ['Talent', talents_with_class_restrictions],
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
      ["#{t.name} (#{t.code})", "t#{t.id}"]
    end
  end
end
