import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:countries/common/models/dio_response.dart';
import 'package:countries/features/detail/models/detail_data_ui_model.dart';
import 'package:countries/features/country/models/country_data_ui_model.dart';

class Repository {
  static Future<DioResponse> fetchCountries() async {
    List<CountryDataUiModel> countries = List<CountryDataUiModel>.empty(growable: true);
    try {
      final response = await Dio().get(
        'https://restcountries.com/v3.1/all',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          contentType: 'application/json',
        ),
      );
      final result = response.data;
      for (int i = 0; i < result.length; i++) {
        CountryDataUiModel country = CountryDataUiModel.fromMap(result[i]);
        countries.add(country);
      }
      return DioSuccessResponse<List<CountryDataUiModel>>(data: countries);
    } on Exception catch(e) {
      log(e.toString());
      return DioErrorResponse(exception: e);
    }
  }

  static Future<DioResponse> fetchCountryDetails(String ccn3) async {
    try {
      final response = await Dio().get(
        'https://restcountries.com/v3.1/alpha/$ccn3',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          contentType: 'application/json',
        ),
      );
      final result = response.data;
      DetailDataUiModel country = DetailDataUiModel.fromJson(result.first);
      return DioSuccessResponse<DetailDataUiModel>(data: country);
    } on Exception catch (e) {
      log(e.toString());
      return DioErrorResponse(exception: e);
    }
  }

  static Future<DioResponse> fetchSearchResults(String name) async {
    List<CountryDataUiModel> countries = List<CountryDataUiModel>.empty(growable: true);
    try {
      final response = await Dio().get(
        'https://restcountries.com/v3.1/name/$name',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          contentType: 'application/json',
        ),
      );
      final result = response.data;
      for (int i = 0; i < result.length; i++) {
        CountryDataUiModel country = CountryDataUiModel.fromMap(result[i]);
        countries.add(country);
      }
      return DioSuccessResponse<List<CountryDataUiModel>>(data: countries);
    } on Exception catch(e) {
      log(e.toString());
      return DioErrorResponse(exception: e);
    }
  }
}