// ignore_for_file: type_literal_in_constant_pattern

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:countries/features/detail/bloc/detail_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class DetailPage extends StatefulWidget {
  final String ccn3;
  final String name;

  const DetailPage({
    super.key,
    required this.name,
    required this.ccn3,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  DetailBloc detailBloc = DetailBloc();
  Connectivity? connectivity;
  late StreamSubscription<List<ConnectivityResult>> connectivitySubscription;

  @override
  void initState() {
    super.initState();
    detailBloc.add(DetailInitialFetchEvent(widget.ccn3));
    connectivity = Connectivity();
    connectivity!.checkConnectivity().then((value) {
      if(value.where((element) => element == ConnectivityResult.mobile || element == ConnectivityResult.wifi || element == ConnectivityResult.ethernet).isNotEmpty) {
        detailBloc.add(DetailInitialFetchEvent(widget.ccn3));
      } else {
        detailBloc.add(DetailNoInternetConnectionEvent());
      }
    });
    connectivitySubscription = connectivity!.onConnectivityChanged.listen((List<ConnectivityResult> result) async {
      final isDeviceConnected = await InternetConnectionChecker().hasConnection;
      if(isDeviceConnected) {
        detailBloc.add(DetailInitialFetchEvent(widget.ccn3));
      } else {
        detailBloc.add(DetailNoInternetConnectionEvent());
      }
    });
  }

  Future<void> onRefresh() async {
    detailBloc.add(DetailInitialFetchEvent(widget.ccn3));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Search Delegate
            },
          ),
        ],
      ),
      body: BlocConsumer<DetailBloc, DetailState>(
        bloc: detailBloc,
        listenWhen: (previous, current) => current is DetailActionState,
        buildWhen: (previous, current) => current is! DetailActionState,
        listener: (context, state) {},
        builder: (context, state) {
          switch (state.runtimeType) {
            case DetailFetchingLoadingState:
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.black,
                    )
                  ],
                ),
              );
            case DetailNoInternetConnectionState:
              return Center(
                child: RefreshIndicator(
                  onRefresh: onRefresh,
                  child: Column(
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
                ),
              );
            case DetailFetchingSuccessfulState:
              final successState = state as DetailFetchingSuccessfulState;
              final country = successState.country;
              return RefreshIndicator(
                onRefresh: onRefresh,
                child: Column(
                  children: [
                    if(country.flags?.png != null)
                      Image.network(
                        country.flags!.png!,
                        width: MediaQuery.of(context).size.width,
                      ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            country.name?.common ?? '',
                            style: const TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_on),
                              Text(
                                country.region ?? '',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            default:
              return const SizedBox();
          }
        },
      ),
    );
  }
}
