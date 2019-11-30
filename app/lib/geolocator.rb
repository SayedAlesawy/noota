# frozen_string_literal: true

# Geolocator gets the country info based on ip
module Geolocator
  def self.country(ip)
    url = "http://ip-api.com/json/#{ip}"

    response = JSON.parse(HTTParty.get(url).body).symbolize_keys!
    country = response[:country]

    country
  end
end
