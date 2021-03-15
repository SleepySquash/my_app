part of 'weather_bloc.dart';

@immutable
abstract class WeatherEvent {}

class WeatherRequested extends WeatherEvent {
  final String city;

  WeatherRequested({required this.city}) : assert(city != null);

  List<Object> get props => [city];
}
