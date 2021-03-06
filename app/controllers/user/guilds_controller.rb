# User guilds controller
class User::GuildsController < ApplicationController
  def show
    @orders = orders

    case params[:id].to_i
    when 0
      # Class guild
      @name = current_user.character.character_class.name
      @characters = characters(current_user.character.character_class,
                               params[:order] ? params[:order] : :achi_points)
    when 1
      # Spec guild (only if user's character has spec)
      unless current_user.character.specialization
        redirect_to user_dashboards_index_path
      end

      @name = current_user.character.specialization.name
      @characters = characters(current_user.character.specialization,
                               params[:order] ? params[:order] : :achi_points)
    else
      redirect_to user_dashboards_index_path
    end
  end

  private

  def characters(class_or_spec, order = :achi_points)
    characters = []
    no_consent_count = 0

    # Build initial characters array + count no consents
    class_or_spec.characters.each do |character|
      no_consent_count += 1 unless character.user.consents.first.guilds
      characters << {
        id: character.id,
        name: character.name_with_titles,
        level: character.level,
        exp: character.experience,
        achi_points: character.achi_points,
        consent: character.user.consents.first.guilds
      }
    end

    # Order by selected order type
    characters.sort_by! do |character|
      character[order.to_sym]
    end.reverse!

    if no_consent_count < 2
      # Only show current user's character if only one
      # other user does not consent (to prevent indirect identification)
      characters.each_with_index do |character, index|
        if character[:id] == current_user.character.id
          character[:position] = index + 1
          character[:total] = characters.count
          return character
        end
      end
    else
      characters.map.with_index do |character, index|
        # Include only consenting users' characters
        if character[:consent]
          character[:position] = index + 1
          character[:total] = characters.count
          character
        else
          nil
        end
      end
    end
  end

  def orders
    [
      ['Úspěchy', :achi_points],
      ['Úroveň', :level],
      ['Zkušenosti', :exp]
    ]
  end
end
