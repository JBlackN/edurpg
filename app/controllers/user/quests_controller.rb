require 'icalendar'

# User quests controller
class User::QuestsController < ApplicationController
  before_action :authorize_user

  def index
    @quests = quests_given

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
      # Mark incomplete
      current_user.character.completed_quests.destroy(@quest)

      # Take skill rewards from user (unless they're awarded by another
      # completed quest)
      @quest.skills.each do |skill|
        if character_skill = current_user.character.character_skills.find_by(
            skill_id: skill.id)
          unless current_user.character.completed_quests.any? { |quest|
            quest.skills.exists?(skill.id)
          } || current_user.character.achievements.any? { |achi|
            achi.skills.exists?(skill.id)
          }
            current_user.character.character_skills.destroy(character_skill)
          end
        end
      end

      # Take item rewards from user (unless they're awarded by another
      # completed quest or achieved achievement)
      @quest.items.each do |item|
        if character_item = current_user.character.character_items.find_by(
            item_id: item.id)
          unless current_user.character.completed_quests.any? { |quest|
            quest.items.exists?(item.id)
          } || current_user.character.achievements.any? { |achi|
            achi.items.exists?(item.id)
          }
            current_user.character.character_items.destroy(character_item)
          end
        end
      end

      # Take title rewards from user (unless they're awarded by another
      # completed quest or achieved achievement)
      @quest.titles.each do |title|
        if character_title = current_user.character.character_titles.find_by(
            title_id: title.id)
          unless current_user.character.completed_quests.any? { |quest|
            quest.titles.exists?(title.id)
          } || current_user.character.achievements.any? { |achi|
            achi.titles.exists?(title.id)
          }
            current_user.character.character_titles.destroy(character_title)
          end
        end
      end

      # Take achievement rewards from user (unless they're awarded by another
      # completed quest)
      @quest.achievements.each do |achievement|
        if character_achi = current_user.character.character_achievements.find_by(
            achievement_id: achievement.id)
          unless current_user.character.completed_quests.any? { |quest|
            quest.achievements.exists?(achievement.id)
          } || current_user.character.achievements.any? { |achi|
            achi.achievements.exists?(achievement.id)
          }
            current_user.character.character_achievements.destroy(character_achi)
          end
        end

        # Also take that achievement's item rewards from user (unless they're
        # awarded by another completed quest or achieved achievement)
        achievement.items.each do |item|
          if character_item = current_user.character.character_items.find_by(
              item_id: item.id)
            unless current_user.character.completed_quests.any? { |quest|
              quest.items.exists?(item.id)
            } || current_user.character.achievements.any? { |achi|
              achi.items.exists?(item.id)
            }
              current_user.character.character_items.destroy(character_item)
            end
          end
        end

        # Also take that achievement's title rewards from user (unless they're
        # awarded by another completed quest or achieved achievement)
        achievement.titles.each do |title|
          if character_title = current_user.character.character_titles.find_by(
              title_id: title.id)
            unless current_user.character.completed_quests.any? { |quest|
              quest.titles.exists?(title.id)
            } || current_user.character.achievements.any? { |achi|
              achi.titles.exists?(title.id)
            }
              current_user.character.character_titles.destroy(character_title)
            end
          end
        end
      end
    else
      # Mark completed (unless already marked)
      unless current_user.character.completed_quests.exists?(@quest.id)
        current_user.character.completed_quests << @quest
      end

      # Give skill rewards to user (unless already given)
      @quest.skills.each do |skill|
        unless current_user.character.skills.exists?(skill.id)
          current_user.character.skills << skill
        end
      end

      # Give item rewards to user (unless already given)
      @quest.items.each do |item|
        unless current_user.character.items.exists?(item.id)
          current_user.character.items << item
        end
      end

      # Give title rewards to user (unless already given)
      @quest.titles.each do |title|
        unless current_user.character.titles.exists?(title.id)
          current_user.character.titles << title
        end
      end

      # Give achievement rewards to user (unless already given)
      @quest.achievements.each do |achievement|
        unless current_user.character.achievements.exists?(achievement.id)
          current_user.character.achievements << achievement
        end

        # Also give that achievement's item rewards to user (unless
        # already given)
        achievement.items.each do |item|
          unless current_user.character.items.exists?(item.id)
            current_user.character.items << item
          end
        end

        # Also give that achievement's title rewards to user (unless
        # already given)
        achievement.titles.each do |title|
          unless current_user.character.titles.exists?(title.id)
            current_user.character.titles << title
          end
        end
      end
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
      ['Velmi jednoduchý', 'very_easy', { class: 'quest-very_easy' }],
      ['Jednoduchý', 'easy', { class: 'quest-easy' }],
      ['Středně obtížný', 'medium', { class: 'quest-medium' }],
      ['Obtížný', 'hard', { class: 'quest-hard' }],
      ['Velmi obtížný', 'very_hard', { class: 'quest-very_hard' }]
    ]
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

  def filter_completed
    filtered = []
    @quests.each do |quest|
      filtered << quest unless current_user.character.completed_quests.exists?(
        quest.id)
    end
    @quests = filtered
  end

  def filter_expired
    filtered = []
    @quests.each do |quest|
      filtered << quest if !quest.deadline || quest.deadline >= DateTime.now
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

  def quests_given
    # Get talents by user's enrolled courses -> array of talent IDs or
    # empty array if no consent
    if current_user.consents.first.classes
      @courses ||= Kos.get_student_courses(current_user.username,
                                           session[:user]['token']).map do |course|
        Talent.find_by(code: course['code']).id
      end
    else
      @courses = []
    end

    # Get quests for the talent + include class/spec quests
    if current_user.character.specialization
      Quest.where(talent_id: @courses).or(
        Quest.where(
          specialization_id: current_user.character.specialization.id).or(
            Quest.where(character_class_id: current_user.character.character_class.id)
          )
      )
    else
      Quest.where(talent_id: @courses).or(
        Quest.where(character_class_id: current_user.character.character_class.id)
      )
    end
  end
end
