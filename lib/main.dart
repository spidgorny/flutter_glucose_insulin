import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

import 'DayData.dart';
import 'SimpleTimeSeriesChart.dart';
import 'Smooth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Glucose Insulin'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DayData day;

  @override
  void initState() {
    super.initState();
    DateTime today = Jiffy().startOf(Units.DAY);
//    print(['today', today]);
    this.day = DayData(today, [
      new Ate("10:30", 0.7),
      new Ate("12:30", 1),
      new Ate("17:00", 1),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: SimpleTimeSeriesChart(
              this.createChartData(),
              // Disable animations for image tests.
              animate: true,
            )),
            Expanded(
                child: ListView.builder(
                    itemCount: day.intake.length,
                    itemBuilder: (context, index) {
                      final item = day.intake[index];

                      return ListTile(
                        title: Text(
                          item.time,
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        subtitle: Text('Meal size: ${item.amount}'),
                      );
                    }))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  List<charts.Series<TimeSeriesSales, DateTime>> createChartData() {
    List<TimeSeriesSales> data = [];
    var today = Jiffy(this.day.date).startOf(Units.DAY);
    data.add(new TimeSeriesSales(today, 0));
    for (var ate in this.day.intake) {
      var ateTime = new DateTime(this.day.date.year, this.day.date.month,
          this.day.date.day, ate.hour, ate.minute);
      data.add(new TimeSeriesSales(
          Jiffy(ateTime).subtract(duration: Duration(minutes: 5)), 0));
      data.add(new TimeSeriesSales(ateTime, (ate.amount * 100).round()));
      var ateTimePlus5 = ateTime.add(Duration(hours: 5));
      data.add(new TimeSeriesSales(ateTimePlus5, 0));
    }
    data.add(new TimeSeriesSales(Jiffy(this.day.date).endOf(Units.DAY), 0));

    data.sort(
        (TimeSeriesSales a, TimeSeriesSales b) => a.time.compareTo(b.time));
    data = smoothSeries(data);

    /////
    final myTabletData = [
      new TimeSeriesSales(Jiffy().dateTime, -50),
      new TimeSeriesSales(Jiffy().add(duration: Duration(minutes: 1)), 100),
    ];

    return [
      new charts.Series<TimeSeriesSales, DateTime>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        data: data,
      ),
      new charts.Series<TimeSeriesSales, DateTime>(
        id: 'Tablet',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        data: myTabletData,
      ),
    ];
  }
}
