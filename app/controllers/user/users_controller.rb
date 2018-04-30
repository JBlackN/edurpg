class User::UsersController < ApplicationController
  before_action :authorize_user

  def show
    respond_to do |format|
      format.html { redirect_to edit_user_user_path(current_user) }
      format.json { send_data data_for_export,
                    type: :json, disposition: 'attachment' }
    end
  end

  def edit
    @character = current_user.character
  end

  def update
    @character = current_user.character
    @character.name = params[:character][:name]

    # Process image
    if params[:character].key?(:image)
      @character.image = img_encode_base64(params[:character][:image])
    end

    if @character.save
      redirect_to edit_user_user_path(current_user)
    else
      render 'edit' # TODO: errors -> view
    end
  end

  def destroy
    current_user.destroy
    redirect_to :logout
  end

  private

  def data_for_export
    data = current_user.to_json(
      include: [
        :permission,
        :consents,
        {
          character: {
            include: [
              :character_class,
              :specialization,
              {
                completed_quests: {
                  include: [
                    :character_class,
                    :specialization,
                    :talent,
                    :skills,
                    :achievements,
                    :items,
                    :titles
                  ]
                }
              },
              {
                talent_trees: {
                  include: {
                    talent_tree_talents: {
                      include: :talent
                    }
                  }
                }
              },
              {
                character_character_attributes: {
                  include: :character_attribute
                }
              },
              {
                character_skills: {
                  include: :skill
                }
              },
              {
                character_achievements: {
                  include: {
                    achievements: {
                      include: [:items, :titles]
                    }
                  }
                }
              },
              {
                character_items: {
                  include: :item
                }
              },
              {
                character_titles: {
                  include: :title
                }
              }
            ]
          }
        }
      ]
    )
    data
  end
end
