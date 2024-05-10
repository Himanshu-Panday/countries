enum DioResponseType {
  success,
  error
}

abstract class DioResponse {
  DioResponseType type;

  DioResponse({required this.type});
}

class DioSuccessResponse<T> implements DioResponse {
  final T data;

  DioSuccessResponse({
    required this.data,
  });

  @override
  DioResponseType type = DioResponseType.success;
}

class DioErrorResponse implements DioResponse {
  final Exception exception;

  DioErrorResponse({
    required this.exception,
  });

  @override
  DioResponseType type = DioResponseType.error;
}