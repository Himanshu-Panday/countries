part of 'detail_bloc.dart';

@immutable
sealed class DetailEvent {}

class DetailInitialFetchEvent extends DetailEvent {
  final String ccn3;

  DetailInitialFetchEvent(this.ccn3);
}

class DetailNoInternetConnectionEvent extends DetailEvent {}