require 'nokogiri'
require 'rest-client'

# Kos API Service
#
# Class provides methods for obtaining data from {KOSapi}[https://kosapi.fit.cvut.cz/projects/kosapi/wiki].
class Kos
  BASE_URL = 'https://kosapi.fit.cvut.cz/api/3'
  NS_ATOM = 'http://www.w3.org/2005/Atom'
  NS_KOS = 'http://kosapi.feld.cvut.cz/schema/3'
  NS_XLINK = 'http://www.w3.org/1999/xlink'

  # Gets courses for each study programme and branch from KOSapi.
  #
  # === Parameters
  #
  # [+token+ :: String] Access token ({Zuul OAAS}[https://github.com/cvut/zuul-oaas]).
  #
  # === Return
  #
  # [Hash] Courses by programme and branch (Hash keys: +programme+, +branch+).
  #
  # === See also
  #
  # - Kos.get_courses_by_programme
  # - Kos.get_courses_by_branch
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

  # Gets courses for bachelor and master study programme from KOSapi.
  #
  # === Parameters
  #
  # [+token+ :: String] Access token ({Zuul OAAS}[https://github.com/cvut/zuul-oaas]).
  #
  # === Return
  #
  # [Hash] Courses by programme (Hash keys: +BI+, +MI+).
  def self.get_courses_by_programme(token)
    response = conn(token)["/courses"].get({
      params: {
        limit: 1000,
        query: 'faculty.code=18000;(state==APPROVED,state==OPEN)',
        detail: 1
      }
    })

    # Extract array of courses from XML
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

    # Delete PI(K)-/(B|M|F)IE-, keep only (B|M)I- (prefered) or (B|M)IK-
    courses.delete_if do |course|
      if course['code'] =~ /^(PI(|K)-|(B|M|F)IE-)/
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

  # Gets courses for each study programme's branch from KOSapi.
  #
  # === Parameters
  #
  # [+token+ :: String] Access token ({Zuul OAAS}[https://github.com/cvut/zuul-oaas]).
  # [+programme_code+ :: String] Study programme code.
  # [+programme_courses+ :: Array] Study programme courses (see Kos.get_courses_by_programme).
  #
  # === Return
  #
  # [Hash] Courses by branch (Hash key: branch name, value: Hash w/ keys: +id+, +code+, +courses+)
  #
  # === See also
  #
  # - Kos.get_courses_by_programme
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

    # Convert branches array to hash w/ branch name as key &
    # initialize empty courses array within
    branches = Hash[branch_list.map { |branch| [branch['name'], {
      'id' => branch['id'],
      'code' => branch['code'],
      'courses' => []
    }] }]

    # Filter out unspecified branches
    unspecified_branch = nil
    branches.each do |branch, data|
      unspecified_branch = branch if data['code'] == '---'
    end
    branches.except!(unspecified_branch) unless unspecified_branch.nil?

    # For each programme course: find whether it belongs to branch
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

  # Gets student's study programme, branch & titles from KOSapi.
  #
  # === Parameters
  #
  # [+username+ :: String] Student's CTU username.
  # [+token+ :: String] Access token ({Zuul OAAS}[https://github.com/cvut/zuul-oaas]).
  #
  # === Return
  #
  # [Hash] Student information (Hash keys: +programme+, +branch+, +titles+).
  def self.get_student_info(username, token)
    response = conn(token)["/students/#{username}"].get
    xml = Nokogiri::XML(response.body)

    titles_pre = xml.xpath('//kos:titlesPre', 'kos' => NS_KOS).text
    branch = xml.xpath('//kos:branch/@xlink:href',
                       'kos' => NS_KOS, 'xlink' => NS_XLINK).text
    programme = xml.xpath('//kos:programme/@xlink:href',
                          'kos' => NS_KOS, 'xlink' => NS_XLINK).text

    titles = []
    titles << 'Bc.' if titles_pre =~ /^.*Bc\..*$/
    titles << 'Ing.' if titles_pre =~ /^.*Ing\..*$/

    {
      'programme' => programme.gsub(/programmes\/(.+)\//, '\1'),
      'branch' => branch.gsub(/branches\/(.+)\//, '\1'),
      'titles' => titles
    }
  end

  # Gets student's enrolled courses in specified semester from KOSapi
  #
  # === Parameters
  #
  # [+username+ :: String] Student's CTU username.
  # [+token+ :: String] Access token ({Zuul OAAS}[https://github.com/cvut/zuul-oaas]).
  # [+semester+ :: String] Semester to get classifications from (default: _all_).
  #
  # === Return
  #
  # [Array of Hash] Student's enrolled courses. Hash keys:
  # - +code+ - normalized course code: eg. MI-PDB.16 -> MI-PDB,
  # - +code_full+ - original course code,
  # - +semester+,
  # - +completed+.
  def self.get_student_courses(username, token, semester = 'none')
    response = conn(token)["/students/#{username}/enrolledCourses"].get({
      params: {
        sem: semester,
        limit: 1000
      }
    })

    Nokogiri::XML(response.body).xpath(
      '//atom:content', 'atom' => NS_ATOM
    ).map do |content|
      {
        'code' => content.xpath(
          './kos:course/@xlink:href',
          'kos' => NS_KOS,
          'xlink' => NS_XLINK
        ).text.gsub(
          /courses\/(.+)\//, '\1'
        ).gsub(
          /^(B|M|F)I(|K|E)-([A-Z0-9]+)(\..+)?$/, '\1I-\3'
        ),

        'code_full' => content.xpath(
          './kos:course/@xlink:href',
          'kos' => NS_KOS,
          'xlink' => NS_XLINK
        ).text.gsub(
          /courses\/(.+)\//, '\1'
        ),

        'semester' => content.xpath(
          './kos:semester/@xlink:href',
          'kos' => NS_KOS,
          'xlink' => NS_XLINK
        ).text.gsub(
          /semesters\/(.+)\//, '\1'
        ),

        'completed' => content.xpath(
          './kos:completed', 'kos' => NS_KOS
        ).text == 'true' ? true : false
      }
    end
  end

  # Gets current semester from KOSapi.
  #
  # === Parameters
  #
  # [+token+ :: String] Access token ({Zuul OAAS}[https://github.com/cvut/zuul-oaas]).
  #
  # === Return
  #
  # [String] Current semester.
  def self.get_current_semester(token)
    response = conn(token)["/semesters/current"].get
    Nokogiri::XML(response.body).xpath('//kos:code', 'kos' => NS_KOS).text
  end

  private

  def self.conn(token, accept = 'application/xml')
    RestClient::Resource.new(BASE_URL, headers: {
      authorization: "Bearer #{token}",
      accept: accept
    })
  end
end
