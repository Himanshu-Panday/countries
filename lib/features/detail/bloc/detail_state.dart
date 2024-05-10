part of 'detail_bloc.dart';

@immutable
sealed class DetailState {}

final class DetailInitial extends DetailState {}

abstract class DetailActionState extends DetailState {}

final class DetailNoInternetConnectionState extends DetailActionState {}

final class DetailFetchingLoadingState extends DetailState {}

final class DetailFetchingSuccessfulState extends DetailState {
  final DetailDataUiModel country;

  DetailFetchingSuccessfulState({required this.country});
}

final class DetailFetchingErrorState extends DetailState {
  final Exception exception;

  DetailFetchingErrorState({required this.exception});
}