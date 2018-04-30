class Admin::ItemsController < ApplicationController
  before_action :authorize_admin_manage_items, except: [:index]
  before_action :authorize_admin, only: [:index]

  def index
    @items = Item.all
  end

  def new
    @items = Item.all
    @rarities = rarities
    @attributes = CharacterAttribute.all
  end

  def edit
    @item = Item.find(params[:id])
    @items = Item.all - [@item]
    @rarities = rarities
    @attributes = CharacterAttribute.all
  end

  def create
    @item = Item.new(item_params)

    # Process image
    if params[:item].key?(:image)
      @item.image = img_encode_base64(params[:item][:image])
    end

    # Process attributes
    if params[:item].key?(:attributes)
      params[:item][:attributes].each do |attribute_id, points|
        @item.add_attribute(CharacterAttribute.find(attribute_id), points)
      end
    end

    if @item.save
      redirect_to admin_items_path
    else
      render 'new' # TODO: errors -> view
    end
  end

  def update
    @item = Item.find(params[:id])

    # Process image
    if params[:item].key?(:image)
      @item.image = img_encode_base64(params[:item][:image])
    end

    # Process attributes
    if params[:item].key?(:attributes)
      @item.item_attributes.clear
      params[:item][:attributes].each do |attribute_id, points|
        @item.add_attribute(CharacterAttribute.find(attribute_id), points)
      end
    end

    if @item.save && @item.update(item_params)
      redirect_to admin_items_path
    else
      render 'edit' # TODO: errors -> view
    end
  end

  def destroy
    @item = Item.find(params[:id])
    @item.destroy

    redirect_to admin_items_path
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :rarity)
  end

  def rarities
    ['poor', 'common', 'uncommon', 'rare', 'epic', 'legendary', 'artifact']
  end
end
