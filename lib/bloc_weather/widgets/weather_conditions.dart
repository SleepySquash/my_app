import 'package:flutter/material.dart';
import 'package:my_app/bloc_weather/models/weather.dart' as model;

class WeatherConditions extends StatelessWidget {
  final model.Weather weather;

  WeatherConditions({Key? key, required this.weather})
      : assert(weather != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.network(weather.imageURL, width: 200, height: 200);
    /*switch (condition) {
      case WeatherCondition.clear:
      case WeatherCondition.lightCloud:
        return Image.asset('assets/clear.png');
        break;
      case WeatherCondition.hail:
      case WeatherCondition.snow:
      case WeatherCondition.sleet:
        return Image.asset('assets/snow.png');
        break;
      case WeatherCondition.heavyCloud:
        return Image.asset('assets/cloudy.png');
        break;
      case WeatherCondition.heavyRain:
      case WeatherCondition.lightRain:
      case WeatherCondition.showers:
        return Image.asset('assets/rainy.png');
        break;
      case WeatherCondition.thunderstorm:
        return Image.asset('assets/thunderstorm.png');
        break;
      default:
        return Image.asset('assets/clear.png');
        break;
    }*/
  }
}
