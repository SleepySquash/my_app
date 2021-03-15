import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_app/bloc_weather/blocs/blocs.dart';

import 'last_updated.dart';
import 'location.dart';
import 'combined_weather_temperature.dart';

class Weather extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Погода')),
      body: Center(
        child:
            BlocBuilder<WeatherBloc, WeatherState>(builder: (context, state) {
          if (state is WeatherInitial) return Text('Выберите город');
          if (state is WeatherLoadInProgress)
            return CircularProgressIndicator();
          if (state is WeatherLoadFailure)
            return Text('Что-то пошло не так :(',
                style: TextStyle(color: Colors.red));
          if (state is WeatherLoadSuccess) {
            final weather = state.weather;
            return ListView(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: Location(location: weather.location),
                ),
                LastUpdated(dateTime: weather.lastUpdated),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 50),
                  child: CombinedWeatherTemperature(weather: weather),
                ),
              ],
            );
          }
          return Text('Что-то пошло не так :(');
        }),
      ),
    );
  }
}
