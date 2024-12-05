import 'package:flutter/material.dart';
import 'package:flutter/painting.dart'; // For RangeValues

class FilterManager {
  static final FilterManager _instance = FilterManager._internal();

  factory FilterManager() {
    return _instance;
  }

  FilterManager._internal();

  Map<String, dynamic> filters = {
    'gender': 'Any',
    'ageRange': const RangeValues(0, 20),
    'breeds': [],
    'maxDistance': null,
  };

  void updateFilters(Map<String, dynamic> newFilters) {
    filters = newFilters;
  }

  void clearFilters() {
    filters = {
      'gender': 'Any',
      'ageRange': const RangeValues(1, 20),
      'breeds': [],
      'maxDistance': null,
    };
  }
}
