require 'base64'
require 'json'
require 'rest-client'

# Usermap API Service
#
# Class provides methods for obtaining data from
# {Usermap API}[https://kosapi.fit.cvut.cz/usermap/doc/rest-api-v1.html].
class Usermap
  BASE_URL = 'https://kosapi.fit.cvut.cz/usermap/v1'

  # Gets user's roles from Usermap API.
  #
  # === Parameters
  #
  # [+username+ :: String] CTU username.
  # [+token+ :: String] Access token ({Zuul OAAS}[https://github.com/cvut/zuul-oaas]).
  #
  # === Return
  #
  # [Hash] User roles (Hash keys: +student+, +teacher+).
  def self.get_roles(username, token)
    response = conn(token)["people/#{username}"].get
    raw_roles = JSON.parse(response.body)['roles']
    roles = { student: [], teacher: [] }

    raw_roles.each do |role|
      # Extract course code from P-role
      matches = role.match(/^P-(.+)-(STUDENT|UCITEL).*$/)
      next if matches.nil?

      # Assign course roles + normalize code if needed
      if matches[2] == 'STUDENT'
        roles[:student] << matches[1]
      else
        roles[:teacher] << {
          'code_full' => matches[1],
          'code' => matches[1].gsub(/^(B|M|F)I(|K|E)-([A-Z0-9]+)(\..+)?$/,
                                    '\1I-\3')
        }
      end
    end

    # Restrict students: only bachelor/master programme
    roles[:student] = nil if roles[:student].empty? &&
                             !raw_roles.include?('B-18000-STUDENT-BAKALAR') &&
                             !raw_roles.include?('B-18000-STUDENT-MAGISTR')

    roles
  end

  # Gets user's full name from Usermap API.
  #
  # === Parameters
  #
  # [+username+ :: String] CTU username.
  # [+token+ :: String] Access token ({Zuul OAAS}[https://github.com/cvut/zuul-oaas]).
  #
  # === Return
  #
  # [String] User's full name.
  def self.get_user_name(username, token)
    response_user = conn(token)["people/#{username}"].get
    raw_user_data = JSON.parse(response_user.body)
    "#{raw_user_data['firstName']} #{raw_user_data['lastName']}"
  end

  # Gets user's photo from Usermap API.
  #
  # === Parameters
  #
  # [+username+ :: String] CTU username.
  # [+token+ :: String] Access token ({Zuul OAAS}[https://github.com/cvut/zuul-oaas]).
  #
  # === Return
  #
  # [String] Base64 encoded user's photo.
  def self.get_user_photo(username, token)
    begin
      'data:image/png;base64, ' + Base64.encode64(
        conn(token, 'image/png')["people/#{username}/photo"].get.body)
    rescue RestClient::ExceptionWithResponse
      nil
    end
  end

  private

  def self.conn(token, accept = 'application/json')
    RestClient::Resource.new(BASE_URL, headers: {
      authorization: "Bearer #{token}",
      accept: accept
    })
  end
end
