class Admin::DashboardsController < ApplicationController
  before_action :authorize_admin

  def index
    # Init
    unless CharacterClass.any?
      class_bc = CharacterClass.create(name: 'Student FIT (Bc)', code: 'BI')
      class_ing = CharacterClass.create(name: 'Student FIT (Ing)', code: 'MI')

      courses = Kos.get_courses(session[:user]['token'])

      # Specializations & Talents

      courses[:branch]['BI'].each do |branch, data|
        spec = class_bc.specializations.create(name: branch, code: data['id'])
        data['courses'].each do |course|
          talent = Talent.find_or_create_by(
            name: course['name'], description: course['description'],
            points: course['credits'], code: course['code'])
          spec.talents << talent
        end
        spec.save
      end

      courses[:branch]['MI'].each do |branch, data|
        spec = class_ing.specializations.create(name: branch, code: data['id'])
        data['courses'].each do |course|
          talent = Talent.find_or_create_by(
            name: course['name'], description: course['description'],
            points: course['credits'], code: course['code'])
          spec.talents << talent
        end
        spec.save
      end

      # Achievement categories
      courses_category = AchievementCategory.create(name: 'Předměty')
      courses_bi_category = courses_category.subcategories.create(
        name: 'Bakalářské')
      courses_mi_category = courses_category.subcategories.create(
        name: 'Magisterské')

      courses[:programme]['BI'].each do |course|
        courses_bi_category.subcategories.create(name: course['name'])
      end

      courses[:programme]['MI'].each do |course|
        courses_mi_category.subcategories.create(name: course['name'])
      end
    end
  end
end
