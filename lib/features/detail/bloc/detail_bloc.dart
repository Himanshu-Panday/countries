import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:countries/common/models/dio_response.dart';
import 'package:countries/common/repos/repository.dart';
import 'package:countries/features/detail/models/detail_data_ui_model.dart';
import 'package:meta/meta.dart';

part 'detail_event.dart';
part 'detail_state.dart';

class DetailBloc extends Bloc<DetailEvent, DetailState> {
  DetailBloc() : super(DetailInitial()) {
    on<DetailInitialFetchEvent>(detailInitialFetchEvent);
    on<DetailNoInternetConnectionEvent>(detailNoInternetConnectionEvent);
  }

  FutureOr<void> detailInitialFetchEvent(DetailInitialFetchEvent event, Emitter<DetailState> emit) async {
    emit(DetailFetchingLoadingState());
    DioResponse dioResponse = await Repository.fetchCountryDetails(event.ccn3);
    switch(dioResponse.type) {
      case DioResponseType.success:
        final successResponse = dioResponse as DioSuccessResponse;
        DetailDataUiModel country = successResponse.data;
        emit(DetailFetchingSuccessfulState(country: country));
        break;
      case DioResponseType.error:
        final errorResponse = dioResponse as DioErrorResponse;
        emit(DetailFetchingErrorState(exception: errorResponse.exception));
        break;
    }
  }

  FutureOr<void> detailNoInternetConnectionEvent(DetailNoInternetConnectionEvent event, Emitter<DetailState> emit) {
    emit(DetailNoInternetConnectionState());
  }
}
