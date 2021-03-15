import 'dart:convert';

import 'package:my_app/bloc_weather/models/weather.dart';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

class WeatherApiClient {
  static const baseURL = 'https://www.metaweather.com';
  final http.Client httpClient;

  WeatherApiClient({required this.httpClient}) : assert(httpClient != null);

  Future<int> getLocationId(String city) async {
    final locationURL = '$baseURL/api/location/search?query=$city';
    final locationResponse = await this.httpClient.get(Uri.parse(locationURL));
    if (locationResponse.statusCode != 200)
      throw Exception('Error getting location ID');

    final locationJson = jsonDecode(locationResponse.body) as List;
    return (locationJson.first)['woeid'];
  }

  Future<Weather> fetchWeather(int locationId) async {
    final weatherURL = '$baseURL/api/location/$locationId';
    final weatherResponse = await this.httpClient.get(Uri.parse(weatherURL));
    if (weatherResponse.statusCode != 200)
      throw Exception('Error getting weather');

    final weatherJson = jsonDecode(weatherResponse.body);
    return Weather.fromJson(weatherJson);
  }
}
