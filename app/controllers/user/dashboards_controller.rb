# User dashboard controller
#
# Currently also handles character sync & refresh.
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
    # Load data from external APIs
    student_info = if current_user.consents.first.info
                     Kos.get_student_info(current_user.username, session[:user]['token'])
                   else
                     { 'programme' => 'BI', 'branch' => '', 'titles' => [] }
                   end
    student_courses

    current_semester = Kos.get_current_semester(session[:user]['token'])
    all_courses = Kos.get_courses_by_programme(session[:user]['token'])[student_info['programme']]
    all_courses = Hash[all_courses.map { |course| [course['code'], {
      'name' => course['name'],
      'description' => course['description'],
      'credits' => course['credits']
    }] }]

    # Use student classifications to load quests (on 1st login only)
    if !current_user.character.character_class && current_user.consents.first.grades
      # Use main admin (= 1st character) as quest giver
      first_character = Character.find(1)
      first_character_id = first_character.id if first_character

      @student_courses.sort_by do |course|
        course['semester']
      end.reverse.each do |course|
        next if course['semester'] == 'invalid'

        # Skip if talent (= course) has some quests already
        # (-> no duplicates/overwrites)
        talent = Talent.find_by(code: course['code'])
        next if !talent || talent.quests.any?
        talent_id = talent.id

        data = Grades.get_student_classifications_all(current_user.username,
                                                      session[:user]['token'],
                                                      course['semester'],
                                                      course['code_full'])
        unless data.nil?
          data.each do |quest_data|
            Quest.create(name: quest_data['name'], difficulty: 'medium',
                         completion_check_id: quest_data['id'],
                         character_id: first_character_id,
                         talent_id: talent_id)
          end
        end
      end
    end

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
      # If has any talent tree: check branch selection/change + sync
      if current_user.character.specialization
        # Assign spec on branch selection/change
        old_spec_tree = current_user.character.talent_trees.where.not(
          specialization_id: nil).take
        if !old_spec_tree ||
            old_spec_tree.specialization_id != current_user.character.specialization.id
          # Replace class/old spec tree with new spec tree
          character_class_tree = current_user.character.talent_trees.where.not(
            character_class_id: nil).take
          character_class_tree.destroy if character_class_tree
          old_spec_tree.destroy if old_spec_tree

          # Create new spec's talent tree from template
          spec = current_user.character.specialization
          spec_tree = spec.talent_trees.where(character_id: nil).take.dup
          spec_tree.specialization_id = spec.id
          spec_tree.save

          # Populate the tree with talents
          spec.talent_trees.where(
            character_id: nil
          ).take.talent_tree_talents.each do |talent|
            # Only add talents corresponding to student's enrolled courses
            next unless @student_courses.any? do |course|
              course['code'] == talent.talent.code
            end

            new_talent = talent.dup
            new_talent.talent_tree_id = spec_tree.id
            new_talent.talent_id = talent.talent.id
            # Unlock talent if course completed
            new_talent.unlocked = @student_courses.select do |course|
              course['code'] == talent.talent.code
            end.first['completed']
            new_talent.save

            spec_tree.talent_tree_talents << new_talent
            spec_tree.save
          end

          current_user.character.talent_trees << spec_tree
          current_user.character.save

          # Replace class/old spec item with spec item + its tree
          current_item_tree = current_user.character.talent_trees.where.not(
            item_id: nil).take
          current_item = current_item_tree.item

          current_item_tree.destroy
          current_user.character.character_items.destroy(
            CharacterItem.find_by(item_id: current_item.id)
          )

          item = spec.item

          # Create new item's talent tree from template
          item_tree = item.talent_trees.where(character_id: nil).take.dup
          item_tree.item_id = item.id
          item_tree.save

          # Populate the tree with talents
          item.talent_trees.where(
            character_id: nil
          ).take.talent_tree_talents.each do |talent|
            # Only add talents corresponding to student's enrolled courses
            next unless @student_courses.any? do |course|
              course['code'] == talent.talent.code
            end

            new_talent = talent.dup
            new_talent.talent_tree_id = item_tree.id
            new_talent.talent_id = talent.talent.id
            # Unlock talent if course completed
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

      # Sync & unlock talents in trees (current semester only)
      talent_trees = current_user.character.talent_trees
      talent_trees = talent_trees.where.not(character_class_id: nil).or(
        talent_trees.where.not(specialization_id: nil).or(
          talent_trees.where.not(item_id: nil)
        )
      )
      current_courses = @student_courses.select do |course|
        course['semester'] == current_semester
      end

      # Add to trees & unlock if course completed
      current_courses.each do |course|
        talent = Talent.find_by(code: course['code'])
        next unless talent
        talent_trees.each do |tree|
          tree_talent = tree.talent_tree_talents.find_by(talent_id: talent.id)
          tree.talent_tree_talents << talent unless tree_talent
          tree_talent.unlocked = true if course['completed']
          tree_talent.save
          tree.save
        end
      end

      # Remove from trees (unenrolled courses)
      if current_user.consents.first.classes
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
      end
    else
      # Does not have any talent tree -> init
      if current_user.character.specialization
        # Student has spec -> create its talent tree from template
        spec = current_user.character.specialization
        spec_tree = spec.talent_trees.where(character_id: nil).take.dup
        spec_tree.specialization_id = spec.id
        spec_tree.save

        # Populate the tree with talents
        spec.talent_trees.where(
          character_id: nil
        ).take.talent_tree_talents.each do |talent|
          # Only add talents corresponding to student's enrolled courses
          next unless @student_courses.any? do |course|
            course['code'] == talent.talent.code
          end

          new_talent = talent.dup
          new_talent.talent_tree_id = spec_tree.id
          new_talent.talent_id = talent.talent.id
          # Unlock talent if course completed
          new_talent.unlocked = @student_courses.select do |course|
            course['code'] == talent.talent.code
          end.first['completed']
          new_talent.save

          spec_tree.talent_tree_talents << new_talent
          spec_tree.save
        end

        current_user.character.talent_trees << spec_tree
        current_user.character.save

        # Student has spec -> create corresponding item and its talent tree
        # from template
        item = spec.item

        item_tree = item.talent_trees.where(character_id: nil).take.dup
        item_tree.item_id = item.id
        item_tree.save

        # Populate the tree with talents
        item.talent_trees.where(
          character_id: nil
        ).take.talent_tree_talents.each do |talent|
          # Only add talents corresponding to student's enrolled courses
          next unless @student_courses.any? do |course|
            course['code'] == talent.talent.code
          end

          new_talent = talent.dup
          new_talent.talent_tree_id = item_tree.id
          new_talent.talent_id = talent.talent.id
          # Unlock talent if course completed
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
        # Student has class (no spec yet) -> create class' talent tree from
        # template
        character_class = current_user.character.character_class
        character_class_tree = character_class.talent_trees.where(
          character_id: nil).take.dup
        character_class_tree.character_class_id = character_class.id
        character_class_tree.save

        # Populate the tree with talents
        character_class.talent_trees.where(
          character_id: nil
        ).take.talent_tree_talents.each do |talent|
          # Only add talents corresponding to student's enrolled courses
          next unless @student_courses.any? do |course|
            course['code'] == talent.talent.code
          end

          new_talent = talent.dup
          new_talent.talent_tree_id = character_class_tree.id
          new_talent.talent_id = talent.talent.id
          # Unlock talent if course completed
          new_talent.unlocked = @student_courses.select do |course|
            course['code'] == talent.talent.code
          end.first['completed']
          new_talent.save

          character_class_tree.talent_tree_talents << new_talent
          character_class_tree.save
        end

        current_user.character.talent_trees << character_class_tree
        current_user.character.save

        # Student has class (no spec yet) -> create class' corresponding item
        # and its talent tree from template
        item = character_class.item

        item_tree = item.talent_trees.where(character_id: nil).take.dup
        item_tree.item_id = item.id
        item_tree.save

        # Populate the tree with talents
        item.talent_trees.where(
          character_id: nil
        ).take.talent_tree_talents.each do |talent|
          # Only add talents corresponding to student's enrolled courses
          next unless @student_courses.any? do |course|
            course['code'] == talent.talent.code
          end

          new_talent = talent.dup
          new_talent.talent_tree_id = item_tree.id
          new_talent.talent_id = talent.talent.id
          # Unlock talent if course completed
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
    if current_user.consents.first.grades
      # Load from Grades if consent
      classifications = {}

      courses_quests_given(@student_courses).each do |quest|
        # Skip if completed already or if has no Grades identifer
        next if current_user.character.character_quests.exists?(
          quest_id: quest.id)
        next if quest.completion_check_id.nil? || quest.completion_check_id.empty?

        # Get all courses with given quest sorted by semester (
        # newest to oldest)
        courses = @student_courses.select do |course|
          course['code'] == quest.talent.code
        end.sort_by { |course| course['semester'] }.reverse

        # Use last quest version (from last semester)
        # Multiple enrollments -> last considered valid
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
          # Complete quest if declared complete by Grades
          current_user.character.completed_quests << quest

          # Give skill rewards
          quest.skills.each do |skill|
            current_user.character.skills << skill
          end

          # Give item rewards
          quest.items.each do |item|
            current_user.character.items << item
          end

          # Give title rewards
          quest.titles.each do |title|
            current_user.character.titles << title
          end

          # Give achievement rewards + any of its rewards
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
    end

    # Attributes
    CharacterAttribute.all.each do |attr|
      unless current_user.character.character_attributes.exists?(attr.id)
        current_user.character.add_attribute(attr)
      end
    end
    current_user.character.save
    current_user.character.character_character_attributes.each do |attr|
      # Compute current attribute values
      attr.points = 0
      current_user.character.items.each do |item|
        # Include owned items' values
        item_attr = attr.character_attribute.item_attributes.find_by(
          character_attribute_id: attr.character_attribute.id, item_id: item.id)
        attr.points += item_attr.points if item_attr && !item_attr.points.nil?

        item_tree = item.talent_trees.where(
          character_id: current_user.character.id).take
        if item_tree
          # Include item's tree's talents' attribute values
          item_tree.talent_tree_talents.each do |talent|
            # Only if talent unlocked
            next unless talent.unlocked
            talent_attr = talent.talent.talent_attributes.where(
              character_attribute_id: attr.character_attribute.id).take
            if talent_attr && !talent_attr.points.nil? && talent_attr.points > 0
              attr.points += talent_attr.points
            end
          end
        end
      end
      attr.save
    end

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
    # Get talents by user's enrolled courses -> array of talent IDs
    courses = student_courses.map do |course|
      Talent.find_by(code: course['code']).id
    end

    # Get quests for the talent
    quests = Quest.where(talent_id: courses)

    # Include class/spec quests if demanded
    if include_class_spec
      if current_user.character.specialization
        quests = quests.or(
          Quest.where(
            specialization_id: current_user.character.specialization.id).or(
              Quest.where(character_class_id: current_user.character.character_class.id)
            )
        )
      else
        quests = quests.or(
          Quest.where(character_class_id: current_user.character.character_class.id)
        )
      end
    end

    quests
  end

  def student_courses
    if current_user.consents.first.classes
      @student_courses ||= Kos.get_student_courses(current_user.username,
                                                   session[:user]['token'])
    else
      @student_courses = []
    end

    @student_courses
  end
end
