// ignore_for_file: type_literal_in_constant_pattern

import 'dart:async';
import 'package:countries/features/country/ui/search_delegate.dart';
import 'package:countries/features/detail/ui/detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:countries/features/country/bloc/country_bloc.dart';
import 'package:countries/features/country/models/country_data_ui_model.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class CountryPage extends StatefulWidget {
  const CountryPage({super.key});

  @override
  State<CountryPage> createState() => _CountryPageState();
}

class _CountryPageState extends State<CountryPage> {
  final CountryBloc countryBloc = CountryBloc();
  Connectivity connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> connectivitySubscription;

  @override
  void initState() {
    super.initState();
    connectivity.checkConnectivity().then((value) {
      if(value.where((element) => element == ConnectivityResult.mobile || element == ConnectivityResult.wifi || element == ConnectivityResult.ethernet).isNotEmpty) {
        countryBloc.add(CountryInitialFetchEvent());
      } else {
        countryBloc.add(CountryNoInternetConnectionEvent());
      }
    });
    connectivitySubscription = connectivity.onConnectivityChanged.listen((List<ConnectivityResult> result) async {
      final isDeviceConnected = await InternetConnectionChecker().hasConnection;
      if(isDeviceConnected) {
        countryBloc.add(CountryInitialFetchEvent());
      } else {
        countryBloc.add(CountryNoInternetConnectionEvent());
      }
    });
  }

  Future<void> onRefresh() async {
    countryBloc.add(CountryInitialFetchEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Countries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              dynamic country = await showSearch(
                context: context,
                delegate: CountrySearchDelegate(
                  connectivity: connectivity,
                ),
              );
              if(country != null && country is CountryDataUiModel) {
                countryBloc.add(
                  CountryNavigateToDetailPageEvent(
                    ccn3: country.ccn3,
                    name: country.name.official,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: BlocConsumer<CountryBloc, CountryState>(
        bloc: countryBloc,
        listenWhen: (previous, current) => current is CountryActionState,
        buildWhen: (previous, current) => current is! CountryActionState,
        listener: (context, state) {
          if(state.runtimeType == CountryNavigateToDetailPageState) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DetailPage(
                  ccn3: (state as CountryNavigateToDetailPageState).ccn3,
                  name: state.name,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          switch (state.runtimeType) {
            case CountryFetchingLoadingState:
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
            case CountryNoInternetConnectionState:
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
            case CountryFetchingSuccessfulState:
              final successState = state as CountryFetchingSuccessfulState;
              List<Widget> listViewChildren = List<Widget>.empty(growable: true);
              for(Region region in Region.values) {
                List<CountryDataUiModel> regionCountries = successState.countries.where((element) => element.regionEnum.name == region.name).toList();
                if(regionCountries.isEmpty) {
                  continue;
                }
                List<Widget> regionCountriesWidgetList = regionCountries.map((e) => ListTile(
                  onTap: () {
                    countryBloc.add(
                      CountryNavigateToDetailPageEvent(
                        ccn3: e.ccn3,
                        name: e.name.official,
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Image.network(
                      e.flag.png,
                      fit: BoxFit.contain,
                    ),
                  ),
                  title: Text(e.name.official),
                  trailing: Text(e.population.toString()),
                  subtitle: Text(e.capital != null && e.capital!.isNotEmpty ? e.capital!.first : ""),
                )).toList();
                Widget regionWidget = ExpansionTile(
                  expansionAnimationStyle: AnimationStyle(
                    curve: Curves.easeInOut,
                    duration: const Duration(milliseconds: 500),
                    reverseCurve: Curves.easeInOut,
                    reverseDuration: const Duration(milliseconds: 500),
                  ),
                  title: Text(
                    region.name,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide.none,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  children: regionCountriesWidgetList,
                );
                listViewChildren.add(regionWidget);
              }
              return RefreshIndicator(
                onRefresh: onRefresh,
                child: ListView(
                  primary: true,
                  shrinkWrap: true,
                  children: listViewChildren,
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
