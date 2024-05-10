part of 'country_bloc.dart';

@immutable
abstract class CountryState {}

abstract class CountryActionState extends CountryState {}

class CountryInitial extends CountryState {}

class CountryFetchingLoadingState extends CountryState {}

class CountryFetchingErrorState extends CountryState {
  final Exception exception;
  CountryFetchingErrorState({
    required this.exception,
  });
}

class CountryFetchingSuccessfulState extends CountryState {
  final List<CountryDataUiModel> countries;
  CountryFetchingSuccessfulState({
    required this.countries,
  });
}

class CountryNoInternetConnectionState extends CountryState {}

class CountryNavigateToDetailPageState extends CountryActionState {
  final String ccn3;
  final String name;

  CountryNavigateToDetailPageState({
    required this.ccn3,
    required this.name,
  });
}