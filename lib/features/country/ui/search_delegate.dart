import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:countries/common/models/dio_response.dart';
import 'package:countries/common/repos/repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class CountrySearchDelegate extends SearchDelegate {
  final Connectivity connectivity;
  late StreamSubscription<List<ConnectivityResult>> connectivitySubscription;
  bool connected = false;

  CountrySearchDelegate({
    required this.connectivity,
  }) {
    connectivity.checkConnectivity().then((value) {
      if(value.where((element) => element == ConnectivityResult.mobile || element == ConnectivityResult.wifi || element == ConnectivityResult.ethernet).isNotEmpty) {
        connected = true;
      } else {
        connected = false;
      }
    });
    connectivitySubscription = connectivity.onConnectivityChanged.listen((List<ConnectivityResult> result) async {
      final isDeviceConnected = await InternetConnectionChecker().hasConnection;
      if(isDeviceConnected) {
        connected = true;
      } else {
        connected = false;
      }
    });
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.length < 3) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Country name must be longer than two letters.",
            )
          ],
        ),
      );
    }
    final future = Repository.fetchSearchResults(query);
    return FutureBuilder<DioResponse>(
      future: future,
      builder: (context, AsyncSnapshot<DioResponse> snapshot) {
        Widget child;
        if(!connected) {
          child = Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.wifi_off,
                  size: 64.0,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'No Internet Connection Found',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                )
              ],
            ),
          );
        } else if(snapshot.connectionState == ConnectionState.done) {
          if(snapshot.hasError || snapshot.data is DioErrorResponse) {
            if((snapshot.data as DioErrorResponse).exception.runtimeType == DioException && ((snapshot.data as DioErrorResponse).exception as DioException).type.name == DioExceptionType.badResponse.name) {
              child = const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'No Country Records Found.',
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              child = const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'An error occurred while fetching data.',
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              );
            }
          } else {
            final countriesData = (snapshot.data as DioSuccessResponse).data;
            if(countriesData.isEmpty) {
              child = const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'No results found for the search term.',
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    )
                  ],
                ),
              );
            } else {
              child = ListView.builder(
                shrinkWrap: true,
                itemCount: countriesData.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Image.network(countriesData[index].flag.png, width: 50, height: 50),
                    title: Text(countriesData[index].name.official),
                    subtitle: Text(countriesData[index].capital?.first ?? ''),
                    onTap: () {
                      close(context, countriesData[index]);
                    },
                  );
                },
              );
            }
          }
        } else {
          child = const Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Colors.black,
                ),
              ],
            ),
          );
        }
        return child;
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}