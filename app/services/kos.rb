require 'nokogiri'
require 'rest-client'

class Kos
  BASE_URL = 'https://kosapi.fit.cvut.cz/api/3'
  NS_ATOM = 'http://www.w3.org/2005/Atom'
  NS_KOS = 'http://kosapi.feld.cvut.cz/schema/3'

  def self.get_courses(token)
    courses_bi = get_courses_by_programme(token)['BI']
    courses_mi = get_courses_by_programme(token)['MI']
    {
      programme: {
        'BI' => courses_bi.uniq { |course| course['name'] },
        'MI' => courses_mi.uniq { |course| course['name'] }
      },
      branch: {
        'BI' => get_courses_by_branch(token, 'BI', courses_bi),
        'MI' => get_courses_by_branch(token, 'MI', courses_mi)
      }
    }
  end

  private

  def self.conn(token, accept = 'application/xml')
    RestClient::Resource.new(BASE_URL, headers: {
      authorization: "Bearer #{token}",
      accept: accept
    })
  end

  def self.get_courses_by_branch(token, programme_code, programme_courses)
    response = conn(token)["/programmes/#{programme_code}/branches"].get({
      params: {
        limit: 1000
      }
    })

    branch_list = Nokogiri::XML(response.body).xpath(
      '//atom:entry', 'atom' => NS_ATOM
    ).map do |content|
      {
        'id' => content.xpath('./atom:id', 'atom' => NS_ATOM).text.split(':').last,
        'code' => content.xpath('./atom:content/kos:code',
                                'atom' => NS_ATOM, 'kos' => NS_KOS).text,
        'name' => content.xpath('./atom:content/kos:name[lang("cs")]',
                                'atom' => NS_ATOM, 'kos' => NS_KOS).text,
      }
    end.sort_by { |branch| branch['name'] }.uniq

    branches = Hash[branch_list.map { |branch| [branch['name'], {
      'id' => branch['id'],
      'code' => branch['code'],
      'courses' => []
    }] }]

    programme_courses.each do |course|
      response = conn(token)["/courses/#{course['code']}/branches"].get({
        params: {
          limit: 1000
        }
      })

      course_branches = Nokogiri::XML(response.body).xpath(
        '//atom:entry', 'atom' => NS_ATOM
      ).map do |content|
        {
          'id' => content.xpath('./atom:id', 'atom' => NS_ATOM).text.split(':').last,
          'code' => content.xpath('./atom:content/kos:code',
                                  'atom' => NS_ATOM, 'kos' => NS_KOS).text,
          'name' => content.xpath('./atom:content/kos:name[lang("cs")]',
                                  'atom' => NS_ATOM, 'kos' => NS_KOS).text,
        }
      end.sort_by { |branch| branch['name'] }.uniq

      course_branches.each do |branch|
        branches[branch['name']]['courses'] << course if branches.key?(branch['name'])
      end
    end

    branches.each { |branch, data| data['courses'].sort_by! { |course| course['name'] } }
    branches
  end

  def self.get_courses_by_programme(token)
    response = conn(token)["/courses"].get({
      params: {
        limit: 1000,
        query: 'faculty.code=18000;(state==APPROVED,state==OPEN)',
        detail: 1
      }
    })

    courses = Nokogiri::XML(response.body).xpath(
      '//atom:content', 'atom' => NS_ATOM
    ).map do |content|
      {
        'code' => content.xpath('./kos:code', 'kos' => NS_KOS).text,
        'name' => content.xpath('./kos:name[lang("cs")]', 'kos' => NS_KOS).text,
        'description' => content.xpath('./kos:description[lang("cs")]', 'kos' => NS_KOS).text,
        'credits' => content.xpath('./kos:credits', 'kos' => NS_KOS).text.to_i
      }
    end

    # Delete (B|M)IE-, keep only (B|M)I- (prefered) or (B|M)IK-
    courses.delete_if do |course|
      if course['code'] =~ /^(B|M)IE-/
        true
      elsif match = course['code'].match(/^(B|M)IK-([A-Z0-9]+)(\..+)?$/)
        if courses.any? { |c| c['code'] =~ /^#{match[1]}I-#{match[2]}(\..+)?$/ }
          true
        else
          false
        end
      else
        false
      end
    end

    # Group courses by normalized code ((B|M)IK -> (B|M)I + remove number suffix)
    courses_grouped = {}
    courses.each do |course|
      code = course['code'].gsub(/^(B|M)IK-/, '\1I-').gsub(/\..+$/, '')
      courses_grouped[code] = [] unless courses_grouped.key?(code)
      courses_grouped[code] << course
    end

    # Sort groups by preference (newest version of course)
    courses_grouped.each do |code, courses|
      courses.sort_by! { |course| course['code'] }.reverse!
    end

    # Reconstruct original array with removed duplicates & normalized codes
    # Split by programme
    results = { 'BI' => [], 'MI' => [] }
    courses_grouped.each do |code, courses|
      course = courses.first
      course['code'] = code

      if code =~ /^BI-/
        results['BI'] << course
      elsif code =~ /^MI-/
        results['MI'] << course
      else
        results['BI'] << course
        results['MI'] << course
      end
    end

    results
  end
end
