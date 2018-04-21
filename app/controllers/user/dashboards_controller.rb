class User::DashboardsController < ApplicationController
  before_action :authorize_user

  def index
    refresh_character

    @character_name_titled = character_name_titled
  end

  private

  def refresh_character
    # FIXME: begin
    current_user.character.titles.clear
    # FIXME: end

    student_info = Kos.get_student_info(current_user.username, session[:user]['token'])
    student_courses = Kos.get_student_courses(current_user.username, session[:user]['token'])

    all_courses = Kos.get_courses_by_programme(session[:user]['token'])[student_info['programme']]
    all_courses = Hash[all_courses.map { |course| [course['code'], {
      'name' => course['name'],
      'description' => course['description'],
      'credits' => course['credits']
    }] }]

    # Titles
    active_title_set = false
    if student_info['titles'].include?('Ing.')
      current_user.character.add_title(Title.find_by(title: 'Ing.'), true)
      active_title_set = true
    end
    if student_info['titles'].include?('Bc.')
      active = active_title_set ? false : true
      current_user.character.add_title(Title.find_by(title: 'Bc.'), active)
    end
    current_user.character.save

    # Level
    credits = student_info['programme'] == 'MI' ? 180 : 0
    student_courses.each do |course|
      next unless course['completed']
      code = course['code'].gsub(/^(.I).?-(...)(\..+)?$/, '\1-\2')
      if all_courses.key?(code)
        credits += all_courses[code]['credits']
      end
    end
    current_user.character.level = (credits / 60.0).ceil
    current_user.character.save

    # Class & spec
    current_user.character.character_class = CharacterClass.find_by(code: student_info['programme'])
    current_user.character.specialization = Specialization.find_by(code: student_info['branch'])
    current_user.character.save

    # Attributes
    CharacterAttribute.all.each do |attr|
      unless current_user.character.character_attributes.exists?(attr.id)
        current_user.character.add_attribute(attr)
      end
    end
    current_user.character.save
  end

  def character_name_titled
    titles_before = []
    titles_after = []

    Character.find(current_user.character.id).titles.each do |title|
      if title.after_name
        titles_after << title.title
      else
        titles_before << title.title
      end
    end

    titles_before.join(' ') +
      " #{current_user.character.name}#{titles_after.empty? ? '' : ', '}" +
      titles_after.join(', ')
  end
end
