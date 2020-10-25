import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

import '../DayData.dart';

void testDayData() {
  DateTime today = Jiffy().startOf(Units.DAY);
  print(['today', today]);
  var day = DayData(today, [
    new Ate(TimeOfDay(hour: 18, minute: 30), 1.0),
  ]);
  print(['day', day]);
  var json = day.toJson();
  print(['json', json]);
  var copy = DayData.fromJson(json);
  print(['copy', copy]);
}

void testDayFill() {
  DateTime today = Jiffy().startOf(Units.DAY);
  var day = DayData(today, [new Ate(TimeOfDay(hour: 08, minute: 30), 1.0)]);
  day.intake.add(new CommentEntry(
      TimeOfDay(hour: 11, minute: 09), 'drank a cup of water'));
  day.intake.add(new Ate(TimeOfDay(hour: 11, minute: 09), 1.2));
  print(day);
  print(day.toJson());
//  JsonEncoder encoder = new JsonEncoder.withIndent('  ');
//  String prettyPrint = encoder.convert(json);
//  print(prettyPrint);
  var replace = new Ate(TimeOfDay(hour: 08, minute: 0), 1.0);
  day.intake[0] = replace;
  print(day);
}
