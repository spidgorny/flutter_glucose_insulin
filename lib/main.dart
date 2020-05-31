import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterglucoseinsulin/ChartAbove.dart';
import 'package:flutterglucoseinsulin/EntryPage.dart';
import 'package:jiffy/jiffy.dart';
import 'package:json_store/json_store.dart';

import 'DayData.dart';

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

//    var keys = await jsonStore.getListLike('%');
//    print(['keys', keys]);

//    DateTime today = this.today();
    String ymd = this.ymd();
//    print(['ymd', ymd]);
    Map<String, dynamic> json = await jsonStore.getItem(ymd);
//    print(['json', json]);
    if (json != null) {
      setState(() {
        this.day = DayData.fromJson(json);
      });
    } else {
      // default
      setState(() {
        this.day = new DayData(this.today(), []);
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
      new Ate(TimeOfDay(hour: 10, minute: 30), 0.7),
      new Ate(TimeOfDay(hour: 12, minute: 30), 1),
      new Ate(TimeOfDay(hour: 17, minute: 00), 1),
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
            Expanded(child: ChartAbove(this.day)),
            Expanded(
                child: this.day != null
                    ? renderMealList()
                    : Center(child: CircularProgressIndicator()))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Ate newVal = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EntryPage()),
          );
          if (newVal != null) {
            this.setState(() {
              this.day.intake.add(newVal);
              this.saveDay();
            });
          }
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  ListView renderMealList() {
    return ListView.builder(
        itemCount: day.intake.length,
        itemBuilder: (context, index) {
          final Ate item = day.intake[index];
          var prev = index > 0 ? day.intake[index - 1] : null;

          return ListTile(
            title: Text(
              item.sTime,
              style: Theme.of(context).textTheme.headline5,
            ),
            subtitle: Text('Meal size: ${item.amount}'),
            trailing: item.hoursSince(prev) != null
                ? Text(
                    'Break: ${(item.hoursSince(prev).inMinutes / 60).toStringAsFixed(2)}h')
                : null,
            onTap: () async {
              Ate newVal = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EntryPage(
                          edit: item,
                        )),
              );
              if (newVal == null) {
                this.setState(() {
                  this.day.intake.remove(item);
                  this.saveDay();
                });
              } else {
                this.setState(() {
                  this.day.intake[index] = newVal;
                  this.saveDay();
                });
              }
            },
          );
        });
  }
}
