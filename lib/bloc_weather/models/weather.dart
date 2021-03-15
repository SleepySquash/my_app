enum WeatherCondition {
  sleet,
  hail,
  snow,
  thunderstorm,
  heavyRain,
  lightRain,
  showers,
  heavyCloud,
  lightCloud,
  clear,
  unknown
}

class Weather {
  final WeatherCondition condition;
  final String formattedCondition;
  final double minTemp;
  final double temp;
  final double maxTemp;
  final double windSpeed;
  final String windDirection;
  final double visibility;
  final double humidity;
  final int locationId;
  final String created;
  final DateTime lastUpdated;
  final String location;
  final String imageURL;

  const Weather({
    required this.condition,
    required this.formattedCondition,
    required this.minTemp,
    required this.temp,
    required this.maxTemp,
    required this.windSpeed,
    required this.windDirection,
    required this.visibility,
    required this.humidity,
    required this.locationId,
    required this.created,
    required this.lastUpdated,
    required this.location,
    required this.imageURL,
  });

  List<Object> get props => [
        condition,
        formattedCondition,
        minTemp,
        temp,
        maxTemp,
        windSpeed,
        windDirection,
        visibility,
        humidity,
        locationId,
        created,
        lastUpdated,
        location,
        imageURL,
      ];

  static Weather fromJson(dynamic json) {
    final consolidatedWeather = json['consolidated_weather'][0];
    return Weather(
      condition: _mapStringToWeatherCondition(
          consolidatedWeather['weather_state_abbr']),
      formattedCondition: consolidatedWeather['weather_state_name'],
      temp: consolidatedWeather['the_temp'] as double,
      minTemp: consolidatedWeather['min_temp'] as double,
      maxTemp: consolidatedWeather['max_temp'] as double,
      windSpeed: consolidatedWeather['wind_speed'] as double,
      windDirection: consolidatedWeather['wind_direction_compass'],
      visibility: consolidatedWeather['visibility'] as double,
      humidity: consolidatedWeather['humidity'] as double,
      locationId: json['woeid'] as int,
      created: consolidatedWeather['created'],
      lastUpdated: DateTime.now(),
      location: json['title'],
      imageURL:
          'https://www.metaweather.com/static/img/weather/png/${consolidatedWeather['weather_state_abbr']}.png',
    );
  }

  static WeatherCondition _mapStringToWeatherCondition(String input) {
    switch (input) {
      case 'sn':
        return WeatherCondition.snow;
      case 'sl':
        return WeatherCondition.sleet;
      case 'h':
        return WeatherCondition.hail;
      case 't':
        return WeatherCondition.thunderstorm;
      case 'hr':
        return WeatherCondition.heavyRain;
      case 'lr':
        return WeatherCondition.lightRain;
      case 's':
        return WeatherCondition.showers;
      case 'hc':
        return WeatherCondition.heavyCloud;
      case 'lc':
        return WeatherCondition.lightCloud;
      case 'c':
        return WeatherCondition.clear;
      default:
        return WeatherCondition.unknown;
    }
  }
}
