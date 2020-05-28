import 'package:vector_math/vector_math.dart';

import 'SimpleTimeSeriesChart.dart';

List<TimeSeriesSales> smoothSeries(List<TimeSeriesSales> data) {
  TimeSeriesSales start = data.first;

  for (var sectionEnd in data.sublist(1)) {
    var dataPlus = interpolateBetween(start, sectionEnd);
    print([start.sales, sectionEnd.sales, dataPlus.length]);
    data.addAll(dataPlus);

    start = sectionEnd;
  }

  data.sort((TimeSeriesSales a, TimeSeriesSales b) => a.time.compareTo(b.time));

  return data;
}

List<TimeSeriesSales> interpolateBetween(
    TimeSeriesSales start, TimeSeriesSales end) {
  List<TimeSeriesSales> data = [];
  var p1 = start.sales;
  var p4 = end.sales;
  var dp = p4 - p1;

  var dStart = start.time.millisecondsSinceEpoch.toDouble();
  var dEnd = end.time.millisecondsSinceEpoch.toDouble();

  for (DateTime date = start.time;
      date.isBefore(end.time);
      date = date.add(Duration(days: 1))) {
    var t = date.millisecondsSinceEpoch.toDouble();
    var dt = t - dStart;
    var range = dEnd - dStart;
//      var height = catmullRom(p1, p2, p3, p4, dt / range);
    var height = p1 + smoothStep(p1 / dp, p4 / dp, dt / range) * dp;
    print([p1, p4, date.day, height]);
    var interPoint = TimeSeriesSales(date, height.round());
    data.add(interPoint);
  }
  return data;
}
