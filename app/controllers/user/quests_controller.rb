require 'icalendar'

class User::QuestsController < ApplicationController
  before_action :authorize_user

  def index
    @quests = Quest.all

    filter_expired unless params[:expired] == '1'
    filter_completed unless params[:completed] == '1'
    filter_by_difficulty(params[:difficulty]) unless !params.key?(
      :difficulty) || params[:difficulty].empty?
    filter_by_groups(params[:groups]) unless !params.key?(
      :groups) || params[:groups].empty?

    @difficulties = difficulties
    @groups = quest_groups
    @params = {
      groups: params[:groups],
      difficulty: params[:difficulty],
      expired: params[:expired],
      completed: params[:completed]
    }

    respond_to do |format|
      format.html # index.html.slim
      format.ics { render plain: ics(@quests) }
    end
  end

  def show
    @quest = Quest.find(params[:id])
    @params = {
      groups: params[:groups],
      difficulty: params[:difficulty],
      expired: params[:expired],
      completed: params[:completed]
    }

    respond_to do |format|
      format.html # show.html.slim
      format.ics { render plain: ics([@quest]) }
    end
  end

  def update
    @quest = Quest.find(params[:id])
    @params = {
      groups: params[:groups],
      difficulty: params[:difficulty],
      expired: params[:expired],
      completed: params[:completed]
    }

    if current_user.character.completed_quests.exists?(@quest.id)
      current_user.character.completed_quests.destroy(@quest)
    else
      current_user.character.completed_quests << @quest
    end

    if @quest.save
      redirect_to user_quest_path(@quest, params: @params)
    else
      render 'edit' # TODO: errors -> view
    end
  end

  private

  def difficulties
    [
      ['Velmi jednoduchý', 'very_easy'],
      ['Jednoduchý', 'easy'],
      ['Středně obtížný', 'medium'],
      ['Obtížný', 'hard'],
      ['Velmi obtížný', 'very_hard']
    ]
  end

  def filter_expired
    filtered = []
    @quests.each do |quest|
      filtered << quest if quest.deadline >= DateTime.now
    end
    @quests = filtered
  end

  def filter_completed
    filtered = []
    @quests.each do |quest|
      filtered << quest unless current_user.character.completed_quests.exists?(
        quest.id)
    end
    @quests = filtered
  end

  def filter_by_difficulty(difficulty)
    filtered = []
    @quests.each do |quest|
      filtered << quest if quest.difficulty == difficulty
    end
    @quests = filtered
  end

  def filter_by_groups(id)
    filtered = []
    id_type = id[0]
    id = id[1..-1].to_i

    @quests.each do |quest|
      case id_type
      when 'c'
        filtered << quest if quest.character_class == CharacterClass.find(id)
      when 's'
        filtered << quest if quest.specialization == Specialization.find(id)
      when 't'
        filtered << quest if quest.talent == Talent.find(id)
      else
        filtered << quest
      end
    end

    @quests = filtered
  end

  def ics(quests)
    calendar = Icalendar::Calendar.new

    quests.each do |quest|
      event = Icalendar::Event.new

      event.summary = quest.name
      event.description = quest.objectives if quest.objectives
      event.dtstart = quest.deadline.strftime('%Y%m%dT%H%M%S') if quest.deadline
      event.dtend = quest.deadline.strftime('%Y%m%dT%H%M%S') if quest.deadline

      calendar.add_event(event)
    end

    calendar.to_ical
  end

  def quest_groups
    [
      ['Povolání', CharacterClass.all.map { |c| [c.name, "c#{c.id}"] }],
      ['Specializace', Specialization.all.order(name: :asc).map { |s| ["#{s.name} (#{s.character_class.code})", "s#{s.id}"] }],
      ['Talent', Talent.all.order(name: :asc).map { |t| ["#{t.name} (#{t.code})", "t#{t.id}"] }],
    ]
  end
end
