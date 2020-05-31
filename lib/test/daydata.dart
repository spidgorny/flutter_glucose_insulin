import 'package:flutter/material.dart';
import 'package:flutterglucoseinsulin/DayData.dart';
import 'package:jiffy/jiffy.dart';

void testDayData() {
  DateTime today = Jiffy().startOf(Units.DAY);
  print(['today', today]);
  var day = DayData(today, [
    new Ate(TimeOfDay(hour: 18, minute: 30), 1),
  ]);
  print(['day', day]);
  var json = day.toJson();
  print(['json', json]);
  var copy = DayData.fromJson(json);
  print(['copy', copy]);
}
