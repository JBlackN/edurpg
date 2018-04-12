require 'nokogiri'
require 'rest-client'

class Kos
  BASE_URL = 'https://kosapi.fit.cvut.cz/api/3'
  NS_ATOM = 'http://www.w3.org/2005/Atom'
  NS_KOS = 'http://kosapi.feld.cvut.cz/schema/3'

  def self.get_courses(token)
    {
      bi: get_course_list(token, 'BI').sort.uniq,
      mi: get_course_list(token, 'MI').sort.uniq
    }
  end

  private

  def self.conn(token, accept = 'application/xml')
    RestClient::Resource.new(BASE_URL, headers: {
      authorization: "Bearer #{token}",
      accept: accept
    })
  end

  def self.get_course_list(token, programme_code)
    response = conn(token)["/programmes/#{programme_code}/courses"].get({
      params: {
        limit: 1000,
        query: 'state==APPROVED,state==OPEN'
      }
    })
    Nokogiri::XML(response.body).xpath(
      '//kos:name[lang("cs")]', 'kos' => NS_KOS).map(&:text)
  end
end
