part of 'weather_bloc.dart';

@immutable
abstract class WeatherState {}

class WeatherInitial extends WeatherState {}

class WeatherLoadInProgress extends WeatherState {}

class WeatherLoadSuccess extends WeatherState {
  final Weather weather;

  WeatherLoadSuccess({required this.weather}) : assert(weather != null);
}

class WeatherLoadFailure extends WeatherState {}
