import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterglucoseinsulin/DayData.dart';
import 'package:jiffy/jiffy.dart';

import 'SimpleTimeSeriesChart.dart';
import 'Smooth.dart';

class ChartAbove extends StatelessWidget {
  final DayData day;
  final fiveHours = Duration(hours: 3);

  ChartAbove(this.day);

  @override
  Widget build(BuildContext context) {
    if (this.day == null) {
      return Center(child: CircularProgressIndicator());
    }

    var chartData = this.createChartData(this.day.onlyAte);
    return SimpleTimeSeriesChart(
      this.createChartSeries(chartData),
      animate: true,
    );
  }

  List<TimeSeriesSales> createChartData(List<Ate> intake) {
    bool debug = false;
    print(['intake', intake]);

    List<TimeSeriesSales> data = [];
    var today = Jiffy(this.day.date).startOf(Units.DAY);
    data.add(new TimeSeriesSales(today, 0)); // start day sleeping and hungry
    if (this.day == null || intake.length == 0) {
      return data;
    }

    var fiveMinutes = Duration(minutes: 5);
    int i = 0;
    for (var ate in intake) {
      var ateTime = new DateTime(this.day.date.year, this.day.date.month,
          this.day.date.day, ate.hour, ate.minute);
      if (debug) print('ate at ${ateTime.hour}:${ateTime.minute}');
      if (ate == intake.first) {
        if (debug) print('  first, add "0" 5 minutes before');
        data.add(new TimeSeriesSales(
            Jiffy(ateTime).subtract(duration: fiveMinutes), 0));
      }
      if (i <= intake.length - 2) {
        if (debug) print('  not last');
        var next = intake[i + 1];
        data.add(valueAfter5hOrUntil(ate, next.dateTime));
      } else {
        if (debug) print(['  no next', i]);
      }

      // main time + 25 min (not so steep)
      var twentyFiveMinutes = Duration(minutes: 25);
      data.add(new TimeSeriesSales(
          ateTime.add(twentyFiveMinutes), (ate.amount * 100).round()));
      i++;
    }

    DateTime lastTime = this.day.date.add(Duration(
        hours: intake.last.time.hour, minutes: intake.last.time.minute));
    data.add(valueAfter5hOrUntil(intake.last, lastTime.add(this.fiveHours)));

    // 0 by night
    data.add(new TimeSeriesSales(Jiffy(this.day.date).endOf(Units.DAY), 0));

    data.sort(
        (TimeSeriesSales a, TimeSeriesSales b) => a.time.compareTo(b.time));
    if (debug)
      print(data
          .map((el) => Jiffy(el.time).Hm + ' [' + el.sales.toString() + ']')
          .toList());
    data = smoothSeries(data);
    return data;
  }

  TimeSeriesSales valueAfter5hOrUntil(Ate ate, DateTime next) {
    bool debug = false;
    var ateTime = new DateTime(this.day.date.year, this.day.date.month,
        this.day.date.day, ate.hour, ate.minute);
    var timeTillNext = next.difference(ate.dateTime);
    if (timeTillNext.compareTo(this.fiveHours) < 0) {
      if (debug)
        print(['  timeTillNext is < than 5h', timeTillNext.toString()]);
      var partialTime = timeTillNext.inSeconds / this.fiveHours.inSeconds;
      var height = (ate.amount * partialTime * 100).round();
      if (debug) print(['  partialTime', partialTime, height]);

      var fiveMinutes = Duration(minutes: 5);
      return new TimeSeriesSales(
          Jiffy(next).subtract(duration: fiveMinutes), height);
    } else {
      var ateTimePlus5 = ateTime.add(this.fiveHours);
      if (debug)
        print([
          '  next food in > than 5h, add "0" at',
          ateTimePlus5.hour.toString() + ':' + ateTimePlus5.minute.toString()
        ]);
      return new TimeSeriesSales(ateTimePlus5, 0);
    }
  }

  List<charts.Series<TimeSeriesSales, DateTime>> createChartSeries(
      List<TimeSeriesSales> chartData) {
    var series = [
      new charts.Series<TimeSeriesSales, DateTime>(
        id: 'Glucose',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        data: chartData,
      ),
    ];
    if (Jiffy(this.day.date).yMd == Jiffy().yMd) {
      final myTabletData = [
        new TimeSeriesSales(Jiffy().dateTime, -50),
        new TimeSeriesSales(Jiffy().add(duration: Duration(minutes: 1)), 120),
      ];
      var today = new charts.Series<TimeSeriesSales, DateTime>(
        id: 'Today',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        data: myTabletData,
      );
      series.add(today);
    }

    var comments = this.day.intake.where((element) => element is CommentEntry);
//    print(['comments', comments.length]);
    comments.map((DayEntry el) {
      var ateTime = new DateTime(this.day.date.year, this.day.date.month,
          this.day.date.day, el.hour, el.minute);
      return new TimeSeriesSales(ateTime, 0); // 0 - height
    }).map((TimeSeriesSales el) {
      var plus = new charts.Series<TimeSeriesSales, DateTime>(
        id: 'Comment#' + el.time.hour.toString(),
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        data: [el],
        strokeWidthPxFn: (TimeSeriesSales sales, _) => 5,
      );
      series.add(plus);
    }).toList();
    print(['series', series.length]);
    return series;
  }
}
