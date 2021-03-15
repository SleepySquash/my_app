import 'package:flutter/material.dart';

import 'package:my_app/bloc_weather/models/models.dart' as models;

import 'temperature.dart';
import 'weather_conditions.dart';

class CombinedWeatherTemperature extends StatelessWidget {
  final models.Weather weather;

  CombinedWeatherTemperature({Key? key, required this.weather})
      : assert(weather != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: WeatherConditions(weather: weather),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Temperature(
                temperature: weather.temp,
                high: weather.maxTemp,
                low: weather.minTemp,
              ),
            ),
          ],
        ),
        Center(
          child: Text(
            weather.formattedCondition,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w200,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
