class User::DashboardsController < ApplicationController
  before_action :authorize_user

  def index
    refresh_character

    @character_name_titled = character_name_titled
    @achievement_points = 0
    current_user.character.achievements.each do |achi|
      @achievement_points += achi.points
    end
  end

  private

  def refresh_character
    student_info = Kos.get_student_info(current_user.username, session[:user]['token'])
    student_courses = Kos.get_student_courses(current_user.username, session[:user]['token'])
    student_semesters = student_courses.map do |course|
      course['semester']
    end.sort.uniq

    current_semester = Kos.get_current_semester(session[:user]['token'])
    all_courses = Kos.get_courses_by_programme(session[:user]['token'])[student_info['programme']]
    all_courses = Hash[all_courses.map { |course| [course['code'], {
      'name' => course['name'],
      'description' => course['description'],
      'credits' => course['credits']
    }] }]

    # Titles
    unless current_user.character.titles.any?
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
    end

    # Class & spec
    current_user.character.character_class = CharacterClass.find_by(
      code: student_info['programme'])
    current_user.character.specialization = Specialization.find_by(
      code: student_info['branch']) unless student_info['branch'].empty?
    current_user.character.save

    # Talent trees & artifact weapons
    if current_user.character.talent_trees.any?
      has_spec_tree = false
      current_user.character.talent_trees.each do |tree|
        has_spec_tree = true if tree.specialization
      end

      if current_user.character.specialization
        current_tree = current_user.character.talent_trees.where.not(
          specialization_id: nil).take
        if !current_tree ||
            current_tree.specialization_id != current_user.character.specialization.id
          # replace class tree with spec tree
          character_class_tree = current_user.character.talent_trees.where.not(
            character_class_id: nil).take
          character_class_tree.destroy if character_class_tree
          current_tree.destroy if current_tree

          spec = current_user.character.specialization
          spec_tree = spec.talent_tree.dup
          spec_tree.specialization_id = spec.id
          spec_tree.save

          spec.talent_tree.talent_tree_talents.each do |talent|
            next unless student_courses.any? do |course|
              course['code'] == talent.talent.code
            end

            new_talent = talent.dup
            new_talent.talent_tree_id = spec_tree.id
            new_talent.talent_id = talent.talent.id
            new_talent.unlocked = student_courses.select do |course|
              course['code'] == talent.talent.code
            end.first['completed']
            new_talent.save

            spec_tree.talent_tree_talents << new_talent
            spec_tree.save
          end

          current_user.character.talent_trees << spec_tree
          current_user.character.save

          # replace class item with spec item + its tree
          current_item_tree = current_user.character.talent_trees.where.not(
            item_id: nil).take
          current_item = current_item_tree.item

          current_item_tree.destroy
          current_user.character.character_items.destroy(
            CharacterItem.find_by(item_id: current_item.id)
          )

          item = spec.item

          item_tree = item.talent_tree.dup
          item_tree.item_id = item.id
          item_tree.save

          item.talent_tree.talent_tree_talents.each do |talent|
            next unless student_courses.any? do |course|
              course['code'] == talent.talent.code
            end

            new_talent = talent.dup
            new_talent.talent_tree_id = item_tree.id
            new_talent.talent_id = talent.talent.id
            new_talent.unlocked = student_courses.select do |course|
              course['code'] == talent.talent.code
            end.first['completed']
            new_talent.save

            item_tree.talent_tree_talents << new_talent
            item_tree.save
          end

          current_user.character.items << item
          current_user.character.talent_trees << item_tree
          current_user.character.save
        end
      end

      # sync talents (current semester only)
      talent_trees = current_user.character.talent_trees
      talent_trees = talent_trees.where.not(character_class_id: nil).or(
        talent_trees.where.not(specialization_id: nil).or(
          talent_trees.where.not(item_id: nil)
        )
      )
      current_courses = student_courses.select do |course|
        course['semester'] == current_semester
      end

      current_courses.each do |course|
        if course['completed']
          talent_trees.each do |tree|
            talent_id = Talent.find_by(code: course['code'])
            talent = tree.talent_tree_talents.find_by(talent_id: talent_id)
            talent.completed = true
            talent.save
          end
        end
      end
    else
      if current_user.character.specialization
        # spec tree
        spec = current_user.character.specialization
        spec_tree = spec.talent_tree.dup
        spec_tree.specialization_id = spec.id
        spec_tree.save

        spec.talent_tree.talent_tree_talents.each do |talent|
          next unless student_courses.any? do |course|
            course['code'] == talent.talent.code
          end

          new_talent = talent.dup
          new_talent.talent_tree_id = spec_tree.id
          new_talent.talent_id = talent.talent.id
          new_talent.unlocked = student_courses.select do |course|
            course['code'] == talent.talent.code
          end.first['completed']
          new_talent.save

          spec_tree.talent_tree_talents << new_talent
          spec_tree.save
        end

        current_user.character.talent_trees << spec_tree
        current_user.character.save

        # spec item + its tree
        item = spec.item

        item_tree = item.talent_tree.dup
        item_tree.item_id = item.id
        item_tree.save

        item.talent_tree.talent_tree_talents.each do |talent|
          next unless student_courses.any? do |course|
            course['code'] == talent.talent.code
          end

          new_talent = talent.dup
          new_talent.talent_tree_id = item_tree.id
          new_talent.talent_id = talent.talent.id
          new_talent.unlocked = student_courses.select do |course|
            course['code'] == talent.talent.code
          end.first['completed']
          new_talent.save

          item_tree.talent_tree_talents << new_talent
          item_tree.save
        end

        current_user.character.items << item
        current_user.character.talent_trees << item_tree
        current_user.character.save
      else
        # class tree
        character_class = current_user.character.character_class
        character_class_tree = character_class.talent_tree.dup
        character_class_tree.character_class_id = character_class.id
        character_class_tree.save

        character_class.talent_tree.talent_tree_talents.each do |talent|
          next unless student_courses.any? do |course|
            course['code'] == talent.talent.code
          end

          new_talent = talent.dup
          new_talent.talent_tree_id = character_class_tree.id
          new_talent.talent_id = talent.talent.id
          new_talent.unlocked = student_courses.select do |course|
            course['code'] == talent.talent.code
          end.first['completed']
          new_talent.save

          character_class_tree.talent_tree_talents << new_talent
          character_class_tree.save
        end

        current_user.character.talent_trees << character_class_tree
        current_user.character.save

        # class item + its tree
        item = character_class.item

        item_tree = item.talent_tree.dup
        item_tree.item_id = item.id
        item_tree.save

        item.talent_tree.talent_tree_talents.each do |talent|
          next unless student_courses.any? do |course|
            course['code'] == talent.talent.code
          end

          new_talent = talent.dup
          new_talent.talent_tree_id = item_tree.id
          new_talent.talent_id = talent.talent.id
          new_talent.unlocked = student_courses.select do |course|
            course['code'] == talent.talent.code
          end.first['completed']
          new_talent.save

          item_tree.talent_tree_talents << new_talent
          item_tree.save
        end

        current_user.character.items << item
        current_user.character.talent_trees << item_tree
        current_user.character.save
      end
    end

    # TODO: Quests
    classifications = {}

    courses_quests_given(student_courses).each do |quest|
      next if current_user.character.character_quests.exists?(
        quest_id: quest.id)
      next if quest.completion_check_id.nil? || quest.completion_check_id.empty?

      courses = student_courses.select do |course|
        course['code'] == quest.talent.code
      end.sort_by { |course| course['semester'] }.reverse

      if courses.first['semester'] == 'invalid'
        next if courses.count == 1
        semester = courses[1]['semester']
        code = courses[1]['code_full']
      else
        semester = courses.first['semester']
        code = courses.first['code_full']
      end

      classifications[quest.talent.code] ||= Grades.get_student_classifications(
        current_user.username, session[:user]['token'], semester, code)

      if !classifications[quest.talent.code].nil? &&
          classifications[quest.talent.code].key?(quest.completion_check_id) &&
          classifications[quest.talent.code][quest.completion_check_id]
        current_user.character.completed_quests << quest
      end
    end

    # Attributes
    CharacterAttribute.all.each do |attr|
      unless current_user.character.character_attributes.exists?(attr.id)
        current_user.character.add_attribute(attr)
      end
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
  end

  def character_name_titled
    titles_before = []
    titles_after = []

    Character.find(current_user.character.id).character_titles.each do |title|
      next unless title.active

      if title.title.after_name
        titles_after << title.title.title
      else
        titles_before << title.title.title
      end
    end

    titles_before.join(' ') +
      " #{current_user.character.name}#{titles_after.empty? ? '' : ', '}" +
      titles_after.join(', ')
  end


  def courses_quests_given(student_courses)
    courses = student_courses.map do |course|
      Talent.find_by(code: course['code']).id
    end
    Quest.where(talent_id: courses)
  end
end
