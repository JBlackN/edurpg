# Admin titles controller
class Admin::TitlesController < ApplicationController
  before_action :authorize_admin_manage_titles, except: [:index]
  before_action :authorize_admin, only: [:index]

  def index
    @titles = Title.all
  end

  def new
    @titles = Title.all
  end

  def edit
    @title = Title.find(params[:id])
    @titles = Title.all - [@title]
  end

  def create
    @title = Title.new(title_params)

    if @title.save
      redirect_to admin_titles_path
    else
      render 'new' # TODO: errors -> view
    end
  end

  def update
    @title = Title.find(params[:id])

    if @title.update(title_params)
      redirect_to admin_titles_path
    else
      render 'edit' # TODO: errors -> view
    end
  end

  def destroy
    @title = Title.find(params[:id])
    @title.destroy

    redirect_to admin_titles_path
  end

  private

  def title_params
    params.require(:title).permit(:title, :after_name)
  end
end
