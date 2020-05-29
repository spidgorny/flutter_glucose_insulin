import 'dart:async';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:json_store/json_store.dart';

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
      title: 'Glucose Insulin Hunger',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Glucose Insulin Hunger'),
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
  final fiveHours = Duration(hours: 3);
  DayData day;

  @override
  void initState() {
    super.initState();
    this.loadFromStorage();
//    this.sampleData();
//    this.saveDay();
    new Timer.periodic(Duration(seconds: 60), (Timer t) => setState(() {}));
  }

  loadFromStorage() async {
    JsonStore jsonStore = JsonStore();
//    DateTime today = this.today();
    String ymd = this.ymd();
//    print(['ymd', ymd]);
    Map<String, dynamic> json = await jsonStore.getItem(ymd);
//    print(['json', json]);
    if (json != null) {
      setState(() {
        this.day = DayData.fromJson(json);
      });
    }
  }

  String ymd() {
    String ymd = Jiffy(this.today()).format('y-MM-dd');
    return ymd;
  }

  /// @deprecated
  void sampleData() {
    DateTime today = this.today();
//    print(['today', today]);
    this.day = DayData(today, [
      new Ate("10:30", 0.7),
      new Ate("12:30", 1),
      new Ate("17:00", 1),
    ]);
  }

  saveDay() async {
    JsonStore jsonStore = JsonStore();
//    DateTime today = this.today();
    String ymd = this.ymd();
    print(['ymd', this.day.toJson()]);
    await jsonStore.setItem(ymd, this.day.toJson());
  }

  DateTime today() {
    DateTime today = Jiffy().startOf(Units.DAY);
    return today;
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
              this.createChartSeries(),
              // Disable animations for image tests.
              animate: true,
            )),
            Expanded(
                child: this.day != null
                    ? renderMealList()
                    : Center(child: CircularProgressIndicator()))
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

  ListView renderMealList() {
    return ListView.builder(
        itemCount: day.intake.length,
        itemBuilder: (context, index) {
          final item = day.intake[index];
          var prev = index > 0 ? day.intake[index - 1] : null;

          return ListTile(
            title: Text(
              item.time,
              style: Theme.of(context).textTheme.headline5,
            ),
            subtitle: Text('Meal size: ${item.amount}'),
            trailing: item.hoursSince(prev) != null
                ? Text(
                    'Break: ${(item.hoursSince(prev).inMinutes / 60).toStringAsFixed(2)}h')
                : null,
          );
        });
  }

  List<TimeSeriesSales> createChartData() {
    List<TimeSeriesSales> data = [];
    if (this.day == null) {
      return data;
    }
    var today = Jiffy(this.day.date).startOf(Units.DAY);
    data.add(new TimeSeriesSales(today, 0)); // start day sleeping and hungry
    var fiveMinutes = Duration(minutes: 5);
    int i = 0;
    for (var ate in this.day.intake) {
      var ateTime = new DateTime(this.day.date.year, this.day.date.month,
          this.day.date.day, ate.hour, ate.minute);
      print('ate at ${ateTime.hour}:${ateTime.minute}');
      if (ate == this.day.intake.first) {
        print('  first, add "0" 5 minutes before');
        data.add(new TimeSeriesSales(
            Jiffy(ateTime).subtract(duration: fiveMinutes), 0));
      }
      if (i <= this.day.intake.length - 2) {
        print('  not last');
        var next = this.day.intake[i + 1];
        var timeTillNext = next.dateTime.difference(ate.dateTime);
        if (timeTillNext.compareTo(this.fiveHours) < 0) {
          print(['  timeTillNext is < than 5h', timeTillNext.toString()]);
          var partialTime = timeTillNext.inSeconds / this.fiveHours.inSeconds;
          var height = (ate.amount * partialTime * 100).round();
          print(['  partialTime', partialTime, height]);
          data.add(new TimeSeriesSales(
              Jiffy(next.dateTime).subtract(duration: fiveMinutes), height));
        } else {
          var ateTimePlus5 = ateTime.add(this.fiveHours);
          print([
            '  next food in > than 5h, add "0" at',
            ateTimePlus5.hour.toString() + ':' + ateTimePlus5.minute.toString()
          ]);
          data.add(new TimeSeriesSales(ateTimePlus5, 0));
        }
      } else {
        print(['  no next', i]);
      }

      // main time + 25 min (not so steep)
      var twentyFiveMinutes = Duration(minutes: 25);
      data.add(new TimeSeriesSales(
          ateTime.add(twentyFiveMinutes), (ate.amount * 100).round()));
      i++;
    }
    data.add(new TimeSeriesSales(Jiffy(this.day.date).endOf(Units.DAY), 0));

    data.sort(
        (TimeSeriesSales a, TimeSeriesSales b) => a.time.compareTo(b.time));
    print(data
        .map((el) => Jiffy(el.time).Hm + ' [' + el.sales.toString() + ']')
        .toList());
    data = smoothSeries(data);
    return data;
  }

  List<charts.Series<TimeSeriesSales, DateTime>> createChartSeries() {
    /////
    final myTabletData = [
      new TimeSeriesSales(Jiffy().dateTime, -50),
      new TimeSeriesSales(Jiffy().add(duration: Duration(minutes: 1)), 120),
    ];

    return [
      new charts.Series<TimeSeriesSales, DateTime>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        data: this.createChartData(),
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
