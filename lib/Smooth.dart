import 'package:vector_math/vector_math.dart';

import 'SimpleTimeSeriesChart.dart';

List<TimeSeriesSales> smoothSeries(List<TimeSeriesSales> data) {
  TimeSeriesSales p1 = data.first;

  var p2 = p1;
  var i = 1;
  for (var sectionEnd in data.sublist(1)) {
    var p3 = sectionEnd;
    var p4 = i < data.length - 1 ? data[i + 1] : data.last;
    print([p1.sales, p2.sales, p3.sales, p4.sales]);
    var dataPlus = interpolateBetween(p1, p2, p3, p4);
    print([p2.sales, sectionEnd.sales, dataPlus.length]);
    data.addAll(dataPlus);

    p1 = p2;
    p2 = p3;
    i++;
  }

  data.sort((TimeSeriesSales a, TimeSeriesSales b) => a.time.compareTo(b.time));
  return data;
}

List<TimeSeriesSales> interpolateBetween(TimeSeriesSales p1, TimeSeriesSales p2,
    TimeSeriesSales p3, TimeSeriesSales p4) {
  List<TimeSeriesSales> data = [];

  var p1d = p1.sales.toDouble();
  var p2d = p2.sales.toDouble();
  var p3d = p3.sales.toDouble();
  var p4d = p4.sales.toDouble();
  var dStart = p2.time.millisecondsSinceEpoch.toDouble();
  var dEnd = p3.time.millisecondsSinceEpoch.toDouble();
  var range = dEnd - dStart;

  for (DateTime date = p2.time;
      date.isBefore(p3.time);
      date = date.add(Duration(days: 1))) {
    var t = date.millisecondsSinceEpoch.toDouble();
    var dt = t - dStart;
    var height = catmullRom(p1d, p2d, p3d, p4d, dt / range);
    print([dStart, dEnd, date.day, height]);
    var interPoint = TimeSeriesSales(date, height.round());
    data.add(interPoint);
  }
  return data;
}
