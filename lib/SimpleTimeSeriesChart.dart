import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutterglucoseinsulin/Smooth.dart';
import 'package:jiffy/jiffy.dart';

class SimpleTimeSeriesChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  SimpleTimeSeriesChart(this.seriesList, {this.animate});

  /// Creates a [TimeSeriesChart] with sample data and no transition.
  factory SimpleTimeSeriesChart.withSampleData() {
    return new SimpleTimeSeriesChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      // Optionally pass in a [DateTimeFactory] used by the chart. The factory
      // should create the same type of [DateTime] as the data provided. If none
      // specified, the default creates local date time.
      dateTimeFactory: const charts.LocalDateTimeFactory(),
      domainAxis: new charts.EndPointsTimeAxisSpec(
          tickProviderSpec: charts.DateTimeEndPointsTickProviderSpec()),
      primaryMeasureAxis: new charts.NumericAxisSpec(
        tickProviderSpec:
            new charts.BasicNumericTickProviderSpec(desiredTickCount: 10),
        viewport: charts.NumericExtents.fromValues(
            [-10, 0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120]),
      ),
      behaviors: [
        // Add the sliding viewport behavior to have the viewport center on the
        // domain that is currently selected.
        new charts.SlidingViewport(),
        // A pan and zoom behavior helps demonstrate the sliding viewport
        // behavior by allowing the data visible in the viewport to be adjusted
        // dynamically.
        new charts.PanAndZoomBehavior(),
        new charts.RangeAnnotation([
          new charts.RangeAnnotationSegment(DateTime.now(),
              Jiffy().endOf(Units.DAY), charts.RangeAnnotationAxisType.domain,
              startLabel: 'Later today',
              endLabel: '',
              labelAnchor: charts.AnnotationLabelAnchor.end,
              color: charts.MaterialPalette.gray.shade200,
              // Override the default vertical direction for domain labels.
              labelDirection: charts.AnnotationLabelDirection.horizontal),
          new charts.RangeAnnotationSegment(
              -10, 0, charts.RangeAnnotationAxisType.measure,
              startLabel: 'Hunger',
              endLabel: '',
              labelAnchor: charts.AnnotationLabelAnchor.end,
              color: charts.MaterialPalette.gray.shade300),
        ])
      ],
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<TimeSeriesSales, DateTime>> _createSampleData() {
    var data = [
      new TimeSeriesSales(new DateTime(2017, 9, 19), 5),
      new TimeSeriesSales(new DateTime(2017, 9, 26), 25),
      new TimeSeriesSales(new DateTime(2017, 10, 3), 100),
      new TimeSeriesSales(new DateTime(2017, 10, 10), 75),
    ];

    data = smoothSeries(data);

    return [
      new charts.Series<TimeSeriesSales, DateTime>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        data: data,
      )
    ];
  }
}

/// Sample time series data type.
class TimeSeriesSales {
  final DateTime time;
  final int sales;

  TimeSeriesSales(this.time, this.sales);
}
