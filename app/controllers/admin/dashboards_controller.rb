# Admin dashboard controller
#
# Currently also initializes application on first admin login.
class Admin::DashboardsController < ApplicationController
  before_action :authorize_admin

  def index
    # Init
    unless CharacterClass.any?
      courses = Kos.get_courses(session[:user]['token'])

      # Classes

      class_bc = CharacterClass.create(name: 'Student FIT (BSP)', code: 'BI')
      class_ing = CharacterClass.create(name: 'Student FIT (MSP)', code: 'MI')

      # Specializations + their talents & talent trees

      courses[:branch]['BI'].each do |branch, data|
        spec = class_bc.specializations.find_or_create_by(name: branch, code: data['id'],
                                                          abbr: data['code'])
        tree = spec.talent_trees.create(width: 1920, height: 1080, talent_size: 50)
        data['courses'].each do |course|
          talent = Talent.find_or_create_by(
            name: course['name'], description: course['description'],
            points: course['credits'], code: course['code'])
          spec.talents << talent
          tree.add_talent(talent, 0, 0)
        end
        tree.save
        spec.save
      end

      courses[:branch]['MI'].each do |branch, data|
        spec = class_ing.specializations.find_or_create_by(name: branch, code: data['id'],
                                                           abbr: data['code'])
        tree = spec.talent_trees.create(width: 1920, height: 1080, talent_size: 50)
        data['courses'].each do |course|
          talent = Talent.find_or_create_by(
            name: course['name'], description: course['description'],
            points: course['credits'], code: course['code'])
          spec.talents << talent
          tree.add_talent(talent, 0, 0)
        end
        tree.save
        spec.save
      end

      # Talent trees for classes

      tree_bc = class_bc.talent_trees.create(width: 1920, height: 1080, talent_size: 50)
      tree_ing = class_ing.talent_trees.create(width: 1920, height: 1080, talent_size: 50)

      courses[:programme]['BI'].each do |course|
        talent = Talent.find_or_create_by(
          name: course['name'], description: course['description'],
          points: course['credits'], code: course['code'])
        tree_bc.add_talent(talent, 0, 0)
      end

      courses[:programme]['MI'].each do |course|
        talent = Talent.find_or_create_by(
          name: course['name'], description: course['description'],
          points: course['credits'], code: course['code'])
        tree_ing.add_talent(talent, 0, 0)
      end

      tree_bc.save
      tree_ing.save

      # Achievement categories
      courses_category = AchievementCategory.create(name: 'Předměty')
      courses_bi_category = courses_category.subcategories.create(
        name: 'Bakalářské')
      courses_mi_category = courses_category.subcategories.create(
        name: 'Magisterské')

      courses[:programme]['BI'].each do |course|
        courses_bi_category.subcategories.create(name: course['name'],
                                                 code: course['code'])
      end

      courses[:programme]['MI'].each do |course|
        courses_mi_category.subcategories.create(name: course['name'],
                                                 code: course['code'])
      end

      # Items (artifact weapons) & their talent trees

      artifact_bc = Item.create(name: "#{class_bc.name} - artefakt",
                                rarity: 'artifact')
      artifact_ing = Item.create(name: "#{class_ing.name} - artefakt",
                                 rarity: 'artifact')

      artifact_bc_tree = artifact_bc.talent_trees.create(
        width: 1920, height: 1080, talent_size: 50)
      artifact_ing_tree = artifact_ing.talent_trees.create(
        width: 1920, height: 1080, talent_size: 50)

      courses[:programme]['BI'].each do |course|
        talent = Talent.find_or_create_by(
          name: course['name'], description: course['description'],
          points: course['credits'], code: course['code'])
        artifact_bc_tree.add_talent(talent, 0, 0)
      end

      courses[:programme]['MI'].each do |course|
        talent = Talent.find_or_create_by(
          name: course['name'], description: course['description'],
          points: course['credits'], code: course['code'])
        artifact_ing_tree.add_talent(talent, 0, 0)
      end

      courses[:branch]['BI'].each do |branch, data|
        artifact_spec = Item.find_or_create_by(
          name: "#{branch} (BI) - artefakt",
          rarity: 'artifact')
        tree_artifact_spec = artifact_spec.talent_trees.create(
          width: 1920, height: 1080, talent_size: 50)

        data['courses'].each do |course|
          talent = Talent.find_or_create_by(
            name: course['name'], description: course['description'],
            points: course['credits'], code: course['code'])
          tree_artifact_spec.add_talent(talent, 0, 0)
        end
        tree_artifact_spec.save
        Specialization.find_by(code: data['id']).item = artifact_spec
      end

      courses[:branch]['MI'].each do |branch, data|
        artifact_spec = Item.find_or_create_by(
          name: "#{branch} (MI) - artefakt",
          rarity: 'artifact')
        tree_artifact_spec = artifact_spec.talent_trees.create(
          width: 1920, height: 1080, talent_size: 50)

        data['courses'].each do |course|
          talent = Talent.find_or_create_by(
            name: course['name'], description: course['description'],
            points: course['credits'], code: course['code'])
          tree_artifact_spec.add_talent(talent, 0, 0)
        end
        tree_artifact_spec.save
        Specialization.find_by(code: data['id']).item = artifact_spec
      end

      class_bc.item = artifact_bc
      class_ing.item = artifact_ing

      # Titles

      Title.create(title: 'Bc.', after_name: false)
      Title.create(title: 'Ing.', after_name: false)

      # Quests
      current_user.permission.class_restrictions.each do |cr|
        # Skip if talent (= course) has some quests already
        # (-> no duplicates/overwrites)
        talent = Talent.find_by(code: cr['code'])
        next if !talent || talent.quests.any?
        talent_id = talent.id

        data = Grades.get_teacher_courses(session[:user]['token'],
                                          cr['code_full'])

        unless data.nil?
          data.each do |quest_data|
            Quest.create(name: quest_data['name'], difficulty: 'medium',
                         completion_check_id: quest_data['id'],
                         character_id: current_user.character.id,
                         talent_id: talent_id)
          end
        end
      end
    end
  end
end
