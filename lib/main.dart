import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

import 'DayData.dart';
import 'SimpleTimeSeriesChart.dart';

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
    print(['today', today]);
    this.day = DayData(today, [
      new Ate("18:30", 1),
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
            Expanded(child: SimpleTimeSeriesChart.withSampleData()),
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
}
