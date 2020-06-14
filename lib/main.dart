import 'dart:async';

import 'package:fab_circular_menu/fab_circular_menu.dart';
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
  DateTime date = DateTime.now();
  DayData day;
  final GlobalKey<FabCircularMenuState> fabKey = GlobalKey();

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

  void saveDay() async {
    JsonStore jsonStore = JsonStore();
//    DateTime today = this.today();
    String ymd = this.ymd();
    print(['ymd', ymd, this.day.toJson()]);
    try {
      await jsonStore.setItem(ymd, this.day.toJson());
    } catch (e) {
      if (e is StorageException) {
        print(e.message);
      }
    }
  }

  DateTime today() {
    DateTime today = Jiffy(this.date).startOf(Units.DAY);
    return today;
  }

  String ymd() {
    String ymd = Jiffy(this.today()).format('y-MM-dd');
    return ymd;
  }

  get isToday {
    print(['isToday', this.ymd(), Jiffy().format('y-MM-dd')]);
    return this.ymd() == Jiffy().format('y-MM-dd');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                this.date = this.date.subtract(Duration(days: 1));
              });
              this.loadFromStorage();
            },
          ),
          IconButton(
            icon: Icon(Icons.today),
            onPressed: () {
              setState(() {
                this.date = DateTime.now();
              });
              this.loadFromStorage();
            },
          ),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: this.isToday
                ? null
                : () {
                    if (this.isToday) {
                      return;
                    }
                    setState(() {
                      this.date = this.date.add(Duration(days: 1));
                    });
                    this.loadFromStorage();
                  },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: ChartAbove(this.day),
              flex: 1,
            ),
            Expanded(
                flex: 2,
                child: this.day != null
                    ? renderMealList()
                    : Center(child: CircularProgressIndicator()))
          ],
        ),
      ),
      floatingActionButton: FabCircularMenu(
        key: this.fabKey,
        children: <Widget>[
          IconButton(
              icon: Icon(
                Icons.add_comment,
                color: Colors.red.shade300,
              ),
              onPressed: () async {
                CommentEntry newVal = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EntryPage(
                            withMealSize: false,
                          )),
                );
                if (newVal != null) {
                  this.setState(() {
                    this.day.intake.add(newVal);
                    this.saveDay();
                  });
                }
                fabKey.currentState.close();
              }),
          IconButton(
            icon: Icon(
              Icons.fastfood,
              color: Colors.white,
            ),
            onPressed: () async {
              Ate newVal = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EntryPage(
                          withMealSize: true,
                        )),
              );
              if (newVal != null) {
                this.setState(() {
                  this.day.intake.add(newVal);
                  this.saveDay();
                });
              }
              fabKey.currentState.close();
            },
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  ListView renderMealList() {
    day.intake.sort((DayEntry a, DayEntry b) =>
        a.time.toString().compareTo(b.time.toString()));
    return ListView.separated(
        separatorBuilder: (context, index) => Divider(
              color: Colors.grey,
            ),
        itemCount: day.intake.length,
        itemBuilder: (context, index) {
          final DayEntry item = day.intake[index];
          var prev = index > 0 ? day.intake[index - 1] : null;

          return ListTile(
            leading: item is CommentEntry
                ? Icon(Icons.comment)
                : Icon(Icons.fastfood),
            title: Text(
              item.sTime,
              style: Theme.of(context).textTheme.headline6,
            ),
            subtitle: item.comment != null && item.comment != ''
                ? Text(item.comment ?? '')
                : null,
            trailing: item.hoursSince(prev) != null
                ? Text((item is Ate ? 'Meal size: ${item.amount}' + "\n" : '') +
                    'Break: ${(item.hoursSince(prev).inMinutes / 60).toStringAsFixed(2)}h')
                : null,
            onTap: () async {
              DayEntry newVal = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EntryPage(
                          edit: item,
                        )),
              );
              if (newVal == null) {
                return;
              }
              if (newVal.comment == EntryPage.deleteCode) {
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
