class User::DashboardsController < ApplicationController
  before_action :authorize_user

  def index
    refresh_character
    @character = current_user.character
    @current_exp = ((@character.experience % 60) / 60.0) * 100
    @activities = build_activity_log
    @quests = courses_quests_given(student_courses, true).where.not(
      deadline: nil
    ).where(
      'deadline > ? AND deadline <= ?', DateTime.now, 14.days.from_now
    ) - @character.completed_quests
  end

  private

  def refresh_character
    student_info = Kos.get_student_info(current_user.username, session[:user]['token'])
    student_courses
    student_semesters = @student_courses.map do |course|
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
      if current_user.character.specialization
        old_spec_tree = current_user.character.talent_trees.where.not(
          specialization_id: nil).take
        if !old_spec_tree ||
            old_spec_tree.specialization_id != current_user.character.specialization.id
          # replace class/old spec tree with new spec tree
          character_class_tree = current_user.character.talent_trees.where.not(
            character_class_id: nil).take
          character_class_tree.destroy if character_class_tree
          old_spec_tree.destroy if old_spec_tree

          spec = current_user.character.specialization
          spec_tree = spec.talent_tree.dup
          spec_tree.specialization_id = spec.id
          spec_tree.save

          spec.talent_tree.talent_tree_talents.each do |talent|
            next unless @student_courses.any? do |course|
              course['code'] == talent.talent.code
            end

            new_talent = talent.dup
            new_talent.talent_tree_id = spec_tree.id
            new_talent.talent_id = talent.talent.id
            new_talent.unlocked = @student_courses.select do |course|
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
            next unless @student_courses.any? do |course|
              course['code'] == talent.talent.code
            end

            new_talent = talent.dup
            new_talent.talent_tree_id = item_tree.id
            new_talent.talent_id = talent.talent.id
            new_talent.unlocked = @student_courses.select do |course|
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
      current_courses = @student_courses.select do |course|
        course['semester'] == current_semester
      end

      current_courses.each do |course|
        talent = Talent.find_by(code: course['code'])
        next unless talent
        talent_trees.each do |tree|
          tree_talent = tree.talent_tree_talents.find_by(talent_id: talent.id)
          tree.talent_tree_talents << talent unless tree_talent
          tree_talent.completed = true if course['completed']
          tree_talent.save
          tree.save
        end
      end

      talent_trees.each do |tree|
        destroy_queue = []

        tree.talent_tree_talents.each do |tree_talent|
          unless @student_courses.any? do |course|
            course['code'] == tree_talent.talent.code
          end
           destroy_queue << tree_talent
          end
        end

        destroy_queue.each do |tree_talent|
          tree.talent_tree_talents.destroy(tree_talent)
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
          next unless @student_courses.any? do |course|
            course['code'] == talent.talent.code
          end

          new_talent = talent.dup
          new_talent.talent_tree_id = spec_tree.id
          new_talent.talent_id = talent.talent.id
          new_talent.unlocked = @student_courses.select do |course|
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
          next unless @student_courses.any? do |course|
            course['code'] == talent.talent.code
          end

          new_talent = talent.dup
          new_talent.talent_tree_id = item_tree.id
          new_talent.talent_id = talent.talent.id
          new_talent.unlocked = @student_courses.select do |course|
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
          next unless @student_courses.any? do |course|
            course['code'] == talent.talent.code
          end

          new_talent = talent.dup
          new_talent.talent_tree_id = character_class_tree.id
          new_talent.talent_id = talent.talent.id
          new_talent.unlocked = @student_courses.select do |course|
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
          next unless @student_courses.any? do |course|
            course['code'] == talent.talent.code
          end

          new_talent = talent.dup
          new_talent.talent_tree_id = item_tree.id
          new_talent.talent_id = talent.talent.id
          new_talent.unlocked = @student_courses.select do |course|
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

    # Quests
    classifications = {}

    courses_quests_given(@student_courses).each do |quest|
      next if current_user.character.character_quests.exists?(
        quest_id: quest.id)
      next if quest.completion_check_id.nil? || quest.completion_check_id.empty?

      courses = @student_courses.select do |course|
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

        quest.skills.each do |skill|
          current_user.character.skills << skill
        end

        quest.items.each do |item|
          current_user.character.items << item
        end

        quest.titles.each do |title|
          current_user.character.titles << title
        end

        quest.achievements.each do |achievement|
          current_user.character.achievements << achievement

          achievement.items.each do |item|
            current_user.character.items << item
          end

          achievement.titles.each do |title|
            current_user.character.titles << title
          end
        end
      end
    end

    # Attributes
    CharacterAttribute.all.each do |attr|
      unless current_user.character.character_attributes.exists?(attr.id)
        current_user.character.add_attribute(attr)
      end
    end
    current_user.character.save

    # Level & experience
    credits = student_info['programme'] == 'MI' ? 180 : 0
    @student_courses.each do |course|
      next unless course['completed']
      code = course['code'].gsub(/^(.I).?-(...)(\..+)?$/, '\1-\2')
      if all_courses.key?(code)
        credits += all_courses[code]['credits']
      end
    end
    current_user.character.level = (credits / 60.0).ceil
    current_user.character.experience = credits
    current_user.character.save
  end

  def build_activity_log(count = 5)
    activity_log = []

    current_user.character.character_skills.each do |skill|
      activity_log << {
        type: :skill,
        attr_id: skill.skill.character_attribute.id,
        name: skill.skill.name,
        image: skill.skill.image,
        datetime: skill.created_at
      }
    end

    current_user.character.character_achievements.each do |achi|
      activity_log << {
        type: :achievement,
        category_id: achi.achievement.achievement_category.id,
        name: achi.achievement.name,
        image: achi.achievement.image,
        datetime: achi.created_at
      }
    end

    current_user.character.character_items.each do |item|
      activity_log << {
        type: :item,
        name: item.item.name,
        image: item.item.image,
        datetime: item.created_at
      }
    end

    current_user.character.character_titles.each do |title|
      activity_log << {
        type: :title,
        name: title.title.title,
        datetime: title.created_at
      }
    end

    activity_log.sort_by do |activity|
      activity[:datetime]
    end.reverse.take(count)
  end

  def courses_quests_given(student_courses, include_class_spec = false)
    courses = student_courses.map do |course|
      Talent.find_by(code: course['code']).id
    end

    quests = Quest.where(talent_id: courses)
    quests = quests.or(
      Quest.where(
        specialization_id: current_user.character.specialization.id).or(
          Quest.where(character_class_id: current_user.character.character_class.id)
        )
    ) if include_class_spec
    quests
  end

  def student_courses
    @student_courses ||= Kos.get_student_courses(current_user.username,
                                                 session[:user]['token'])
    @student_courses
  end
end
