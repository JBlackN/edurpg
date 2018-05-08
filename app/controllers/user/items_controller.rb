# User items controller
class User::ItemsController < ApplicationController
  before_action :authorize_user

  def index
    @rarities = rarities
    @character_items = current_user.character.items
    @unobtained_items = if params.key?(:all) && params[:all] == '1'
                          Item.all - @character_items
                        else
                          []
                        end
    filter_by_quality
    filter_by_attribute
  end

  private

  def filter_by_quality
    unless !params.key?(:quality) || params[:quality].empty?
      filtered_character_items = []
      filtered_unobtained_items = []

      @character_items.each do |item|
        filtered_character_items << item if item.rarity == params[:quality]
      end
      @unobtained_items.each do |item|
        filtered_unobtained_items << item if item.rarity == params[:quality]
      end

      @character_items = filtered_character_items
      @unobtained_items = filtered_unobtained_items
    end
  end

  def filter_by_attribute
    unless !params.key?(:attr) || params[:attr].empty?
      filtered_character_items = []
      filtered_unobtained_items = []

      @character_items.each do |item|
        if item.character_attributes.exists?(params[:attr].to_i)
          points = item.item_attributes.find_by(
            character_attribute_id: params[:attr].to_i).points
          filtered_character_items << item if !points.nil? && points > 0
        end
      end
      @unobtained_items.each do |item|
        if item.character_attributes.exists?(params[:attr].to_i)
          points = item.item_attributes.find_by(
            character_attribute_id: params[:attr].to_i).points
          filtered_unobtained_items << item if !points.nil? && points > 0
        end
      end

      @character_items = filtered_character_items
      @unobtained_items = filtered_unobtained_items
    end
  end

  def rarities
    [
      ['Špatný', 'poor'],
      ['Běžný', 'common'],
      ['Neobvyklý', 'uncommon'],
      ['Vzácný', 'rare'],
      ['Epický', 'epic'],
      ['Legendární', 'legendary'],
      ['Artefakt', 'artifact']
    ]
  end
end
