part of 'country_bloc.dart';

@immutable
abstract class CountryEvent {}

class CountryInitialFetchEvent extends CountryEvent {}

class CountryNoInternetConnectionEvent extends CountryEvent {}

class CountryNavigateToDetailPageEvent extends CountryEvent {
  final String ccn3;
  final String name;

  CountryNavigateToDetailPageEvent({
    required this.ccn3,
    required this.name,
  });
}