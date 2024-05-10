import 'dart:convert';
import 'package:flutter/cupertino.dart';

class Name {
  final String common;
  final String official;

  Name({
    required this.common,
    required this.official,
  });

  Map<String, dynamic> toMap() {
    return {
      'common': common,
      'official': official,
    };
  }

  factory Name.fromMap(Map<String, dynamic> map) {
    return Name(
      common: map['common'] ?? '',
      official: map['official'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Name.fromJson(String source) => Name.fromMap(json.decode(source));
}

class Flag {
  final String png;
  final String svg;
  final String alt;

  Flag({
    required this.png,
    required this.svg,
    required this.alt,
  });

  Map<String, dynamic> toMap() {
    return {
      'png': png,
      'svg': svg,
      'alt': alt,
    };
  }

  factory Flag.fromMap(Map<String, dynamic> map) {
    return Flag(
      png: map['png'] ?? '',
      svg: map['svg'] ?? '',
      alt: map['alt'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Flag.fromJson(String source) => Flag.fromMap(json.decode(source));
}

enum Region {
  africa(name: 'Africa'),
  americas(name: 'Americas'),
  asia(name: 'Asia'),
  europe(name: 'Europe'),
  oceania(name: 'Oceania'),
  polar(name: 'Polar'),
  antarctic(name: 'Antarctic'),
  none(name: 'None');

  final String name;

  const Region({required this.name});
}

class CountryDataUiModel {
  final Name name;
  final List<String>? capital;
  final int population;
  final String ccn3;
  final String region;
  final Region regionEnum;
  final String subregion;
  final Flag flag;

  CountryDataUiModel({
    required this.name,
    required this.capital,
    required this.population,
    required this.region,
    required this.subregion,
    required this.flag,
    required this.ccn3,
  })
  : regionEnum = Region.values.firstWhere((element) {
    return element.name == region;
  }, orElse: () {
    debugPrint('Region not found: $region');
    return Region.none;
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name.toMap(),
      'capital': capital,
      'population': population,
      'region': region,
      'subregion': subregion,
      'flag': flag.toMap(),
    };
  }

  factory CountryDataUiModel.fromMap(Map<String, dynamic> map) {
    return CountryDataUiModel(
      name: Name.fromMap(map['name'] ?? {}),
      capital: List<String>.from(map['capital'] ?? const []),
      population: map['population'] ?? 0,
      region: map['region'] ?? '',
      subregion: map['subregion'] ?? '',
      flag: Flag.fromMap(map['flags'] ?? {}),
      ccn3: map['ccn3'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory CountryDataUiModel.fromJson(String source) => CountryDataUiModel.fromMap(json.decode(source));
}