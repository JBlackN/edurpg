require 'json'
require 'rest-client'

class Grades
  BASE_URL = 'https://grades.fit.cvut.cz/api/v1/public'

  def self.get_student_classifications(username, token, semester, course)
    response = conn(token)[
      "courses/#{course}/student-classifications/#{username}"
    ].get({
      params: {
        semester: semester,
        lang: 'cs',
        showHidden: false
      }
    })

    return nil unless response.code == 200
    data = JSON.parse(response.body)['studentClassificationFullDtos']
    return nil if data.empty?

    classifications = {}

    data.each do |item|
      next unless ['HOMEWORK', 'SEMESTRAL_TEST'].include?(
        item['classificationType'])
      next if item['calculated']

      classifications[item['identifier']] =
        case item['valueType']
        when 'NUMBER'
          min = item['minimumRequiredValue']
          min = min.nil? ? 0.0 : min.to_f
          if item['value'].nil?
            false
          else
            item['value'].to_f >= min
          end
        when 'BOOLEAN'
          item['value'].nil? ? false : item['value']
        end
    end

    classifications
  end

  def self.get_student_classifications_all(username, token, semester, course)
    begin
      response = conn(token)[
        "courses/#{course}/student-classifications/#{username}"
      ].get({
        params: {
          semester: semester,
          lang: 'cs',
          showHidden: false
        }
      })
    rescue RestClient::Exception
      return nil
    end

    return nil unless response.code == 200
    data = JSON.parse(response.body)['studentClassificationFullDtos']
    return nil if data.empty?

    classifications = []

    data.each do |item|
      next unless ['HOMEWORK', 'SEMESTRAL_TEST'].include?(
        item['classificationType'])
      next if item['calculated']

      classifications << {
        'name' => item['classificationTextDtos'][0]['name'],
        'id' => item['identifier']
      }
    end

    classifications
  end

  def self.get_teacher_courses(token, course)
    begin
      response = conn(token)[
        "courses/#{course}/classifications"
      ].get({
        params: {
          lang: 'cs'
        }
      })
    rescue RestClient::Exception
      return nil
    end

    return nil unless response.code == 200
    data = JSON.parse(response.body)
    return nil if data.empty?

    classifications = []

    data.each do |item|
      next unless ['HOMEWORK', 'SEMESTRAL_TEST'].include?(
        item['classificationType'])
      next if item['calculated']

      classifications << {
        'name' => item['classificationTextDtos'][0]['name'],
        'id' => item['identifier']
      }
    end

    classifications
  end

  private

  def self.conn(token, accept = 'application/json')
    RestClient::Resource.new(BASE_URL, headers: {
      authorization: "Bearer #{token}",
      accept: accept
    })
  end
end
