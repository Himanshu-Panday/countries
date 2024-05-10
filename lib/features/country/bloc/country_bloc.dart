import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:countries/features/country/models/country_data_ui_model.dart';
import 'package:countries/common/models/dio_response.dart';
import 'package:countries/common/repos/repository.dart';
import 'package:meta/meta.dart';

part 'country_event.dart';
part 'country_state.dart';

class CountryBloc extends Bloc<CountryEvent, CountryState> {
  CountryBloc() : super(CountryInitial()) {
    on<CountryInitialFetchEvent>(countryInitialFetchEvent);
    on<CountryNoInternetConnectionEvent>(countryNoInternetConnectionEvent);
    on<CountryNavigateToDetailPageEvent>(countryNavigateToDetailPageEvent);
  }

  FutureOr<void> countryInitialFetchEvent(
    CountryInitialFetchEvent event, Emitter<CountryState> emit
  ) async {
    emit(CountryFetchingLoadingState());
    DioResponse dioResponse = await Repository.fetchCountries();
    switch(dioResponse.type) {
      case DioResponseType.success:
        final successResponse = dioResponse as DioSuccessResponse;
        List<CountryDataUiModel> countries = successResponse.data;
        emit(CountryFetchingSuccessfulState(countries: countries));
        break;
      case DioResponseType.error:
        final errorResponse = dioResponse as DioErrorResponse;
        emit(CountryFetchingErrorState(exception: errorResponse.exception));
        break;
    }
  }

  FutureOr<void> countryNoInternetConnectionEvent(
    CountryNoInternetConnectionEvent event, Emitter<CountryState> emit
  ) async {
    emit(CountryNoInternetConnectionState());
  }

  FutureOr<void> countryNavigateToDetailPageEvent(
    CountryNavigateToDetailPageEvent event, Emitter<CountryState> emit
  ) async {
    emit(CountryNavigateToDetailPageState(ccn3: event.ccn3, name: event.name));
  }
}
