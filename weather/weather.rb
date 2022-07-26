require 'net/http'
require 'json'

class Requests
  attr_reader :base_url, :secret_key, :lat, :lon, :kwargs

  def initialize(base_url:, secret_key:, lat:, lon:, **kwargs)
    @base_url = base_url
    @secret_key = secret_key
    @lat = lat
    @lon = lon
    @kwargs = kwargs
  end

  def make_request!
    make_request()
  end

  private

  def make_request
    uri = URI.parse(base_url)
    uri.query = URI.encode_www_form(request_params)

    http = Net::HTTP.new(uri.hostname)
    
    request = Net::HTTP::Get.new(uri.request_uri)

    request['X-Yandex-API-Key'] = secret_key
    
    response = http.request(request)

    JSON.parse(response.body)
  end

  def request_params
    params = {
      lat: lat,
      lon: lon 
    }

    params.merge!(kwargs) unless kwargs.empty?
  end
end


class Weather
  WEATHER_URL = 'https://api.weather.yandex.ru/v2/forecast'
  WEATHER_KEY = '' # Здесь должен быть секретный ключ Яндекс.Погода

  def initialize(lat:, lon:, **kwargs)
    @requests_obj = Requests.new(base_url: WEATHER_URL, secret_key: WEATHER_KEY, lat: lat, lon: lon, **kwargs)
  end
end


class WeatherReporter < Weather
  attr_reader :requests_obj, :response

  def get_weather
    requests_obj.make_request!()
  end

  def get_temp_weather
    @response = requests_obj.make_request!()

    processing_response
  end

  private

  def processing_response
    fact = response['fact']
    geo_object = response['geo_object']

    locality = geo_object['locality']
    province = geo_object['province']

    "В городе: #{locality['name']}, #{province['name']} температура воздуха на сегодня: #{fact['temp']} градусов"
  end
  
end


class WeatherPredicter < WeatherReporter
  attr_reader :response

  def initialize(lat:, lon:, **kwargs)
    super
  end

  def weather_for_tomorrow
    weather_for_several_days[-1]
  end

  def display_weather_for_several_days
    res = weather_for_several_days.each do |data|
      p "Погода на #{data[:date]}: #{data[:temp]} градусов(ca)"
    end
  end

  def weather_for_several_days
    @response = get_weather

    processing_response
  end

  private

  def processing_response
    forecasts = response['forecasts']

    data = forecasts.map do |cast|
      date = cast['date']
      temp = cast['parts']['day_short']['temp']

      {date: date, temp: temp}
    end

    data
  end
end


class FoilPackage
  attr_reader :cost, :open

  def open!
    raise NotImplementedError
  end

  def open?
    raise NotImplementedError
  end
end


class IceCream
  attr_reader :cost, :package, :empty, :closed


  def initialize
    @cost = 2
    @package = FoilPackage.new
    @empty = false
  end

  def eat!
    # raise if empty
    raise if empty

    # raise if closed
    raise unless open?

    @empty = true
    p "I'm now empty!"
  end
end


class IceCreamFactory
  attr_reader :produced_goods, :weather_obj

  PRODUCT_CLASS = IceCream

  HOT_TEMP = 30
  CHILLY_TEMP = 10

  def initialize(name:, weather_obj:)
    @name = name
    @weather_obj = weather_obj
    @produced_goods = []
  end

  def produce!(quantity:)
    temp = get_weather[:temp].to_i

    if temp > HOT_TEMP
      quantity *= 1.5
    elsif temp < CHILLY_TEMP
      quantity /= 2
    end

    batch =[]

    quantity.times do
      batch << PRODUCT_CLASS.new
    end

    @produced_goods += batch

    batch
  end

  private

  def get_weather
    weather_obj.weather_for_tomorrow
  end
end

# weather_reporter = WeatherReporter.new(lat: '61.2500000', lon: '73.4166700', lang: 'ru_RU').get_temp_weather
# p weather_reporter

# weather_predicter = WeatherPredicter.new(lat: '61.2500000', lon: '73.4166700', lang: 'ru_RU', limit: 7, hours: false).display_weather_for_several_days
# weather_predicter

weather_predicter = WeatherPredicter.new(lat: '61.2500000', lon: '73.4166700', lang: 'ru_RU', limit: 2, hours: false)

batch = IceCreamFactory.new(name: 'ICE', weather_obj: weather_predicter).produce!(quantity: 10)
p batch.count