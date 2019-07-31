require 'bundler/setup'

require 'json'
require 'httparty'
require 'date'

def lambda_handler(event:, context:)
  event['Records'].each do |record|
    city = take_city_from_record(record)
    data = get_weather_forcast_data(city)
    data.each do |l|
      puts l.inspect
    end
  end

  display_message(200, "OK")
rescue => error
  display_message(400, error.message)
end

def save_time
  DateTime.now.new_offset(Rational(9, 24)).strftime('%Y%m%d')
end

def display_message(status_code, message)
  {
    statusCode: status_code,
    body: {
      message: message
    }.to_json
  }
end

def take_city_from_record(record)
  JSON.parse(record['body'])['city']
end

def get_weather_forcast_data(city)
  apikey = ENV['APIKEY']
  raise "Does not exist APIKEY" if apikey == 'None'
  response = HTTParty.get("https://api.openweathermap.org/data/2.5/forecast?q=#{city},jp&appid=#{apikey}")
  raise "[city: #{city}] Failed to get information" if response.code != 200
  JSON.parse(response.body)['list']
end
