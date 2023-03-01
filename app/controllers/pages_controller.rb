require 'httparty'
require 'date'

class PagesController < ApplicationController

  def home
    @elec_response = elec_usage
    @gas_response = gas_usage
    @weather = temp["data"]["weather"]
    @arr = []
    @weather.each do |day|
      datestr = day["date"]
      day["hourly"].each do |hour|
        tempC = hour["tempC"]
        timestr = hour["time"].split('')
        a = timestr[0..-3].join.to_i
        current_time = Time.parse("#{a}:00:00", Date.parse(datestr))
        iso8601_str = current_time.strftime("%Y-%m-%dT%H:%M:%SZ")
        @arr << [iso8601_str, tempC]
      end
    end
  end

  private

  def elec_usage
    three_days_ago = (Date.today - 4).strftime('%Y-%m-%dT%H:%M:%SZ')
    two_days_ago = (Date.today - 2).strftime('%Y-%m-%dT%H:%M:%SZ')
    url = "https://api.octopus.energy/v1/electricity-meter-points/1900029024105/meters/22L4129188/consumption/?period_from=#{three_days_ago}&period_to=#{two_days_ago}"
    auth = {
      username: ENV['OCTOPUS_KEY'],
      password: ''
    }
    response = HTTParty.get(url, basic_auth: auth)
    return response["results"]
  end

  def gas_usage
    three_days_ago = (Date.today - 4).strftime('%Y-%m-%dT%H:%M:%SZ')
    two_days_ago = (Date.today - 2).strftime('%Y-%m-%dT%H:%M:%SZ')
    url = "https://api.octopus.energy/v1/gas-meter-points/605522009/meters/E6S17343472261/consumption/?period_from=#{three_days_ago}&period_to=#{two_days_ago}"
    auth = {
      username: ENV['OCTOPUS_KEY'],
      password: ''
    }
    response = HTTParty.get(url, basic_auth: auth)
    return response["results"]
  end

  def temp
    @date_today = (Date.today - 2).strftime('%F')
    @date_three_days_ago = (Date.today - 4).strftime('%F')
    ENV['WEATHER_KEY']
    url = "https://api.worldweatheronline.com/premium/v1/past-weather.ashx?key=#{ENV['WEATHER_KEY']}&q=kt2&date=#{@date_three_days_ago}&enddate=#{@date_today}&format=json&tp=1"
    response = HTTParty.get(url)
  end
end
