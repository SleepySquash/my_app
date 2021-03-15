import 'package:meta/meta.dart';

import 'package:my_app/bloc_weather/models/weather.dart';
import 'weather_api_client.dart';

class WeatherRepository {
  final WeatherApiClient weatherApiClient;

  WeatherRepository({required this.weatherApiClient})
      : assert(weatherApiClient != null);

  Future<Weather> getWeather(String city) async {
    final locationID = await weatherApiClient.getLocationId(city);
    return weatherApiClient.fetchWeather(locationID);
  }
}
