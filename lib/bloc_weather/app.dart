import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'package:my_app/bloc_weather/blocs/blocs.dart';
import 'package:my_app/bloc_weather/repositories/repositories.dart';
import 'package:my_app/bloc_weather/widgets/widgets.dart';

import 'blocs/simple_bloc_observer.dart';

void myMain() {
  Bloc.observer = SimpleBlocObserver();

  WeatherRepository weatherRepository = WeatherRepository(
    weatherApiClient: WeatherApiClient(httpClient: http.Client()),
  );

  runApp(WeatherApp(weatherRepository: weatherRepository));
}

class WeatherApp extends StatelessWidget {
  final WeatherRepository weatherRepository;

  WeatherApp({Key? key, required this.weatherRepository})
      : assert(weatherRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData.dark(),
      home: BlocProvider(
        create: (context) => WeatherBloc(weatherRepository: weatherRepository)
          ..add(WeatherRequested(city: "St Petersburg")),
        child: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Weather(),
      ),
    );
  }
}
