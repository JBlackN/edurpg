require 'json'
require 'rest-client'

class Usermap
  BASE_URL = 'https://kosapi.fit.cvut.cz/usermap/v1'

  def self.get_roles(username, token)
    response = conn(token)["people/#{username}"].get
    raw_roles = JSON.parse(response.body)['roles']
    roles = { student: [], teacher: [] }

    raw_roles.each do |role|
      matches = role.match(/^P-(..-...)-(STUDENT|UCITEL).*$/)
      next if matches.nil?

      if matches[2] == 'STUDENT'
        roles[:student] << matches[1]
      else
        roles[:teacher] << matches[1]
      end
    end

    roles[:student] = nil if roles[:student].empty? &&
                             !raw_roles.include?('B-18000-STUDENT')

    roles
  end

  private

  def self.conn(token)
    RestClient::Resource.new(BASE_URL, headers: {
      authorization: "Bearer #{token}",
      accept: 'application/json'
    })
  end
end
