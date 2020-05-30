import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:jiffy/jiffy.dart';

import 'DayData.dart';

class EntryPage extends StatefulWidget {
  final Ate edit;

  EntryPage({this.edit});

  @override
  _EntryPageState createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  double _lowerValue = 1;
//  double _upperValue;

  Map<double, String> options = {
    0.25: 'light snack',
    0.5: 'half a meal',
    0.75: '3/4 of a meal',
    1.0: 'standard serving',
    1.25: 'standard + dessert',
    1.5: 'finish spouse' 's plate',
    1.75: 'hard to breathe',
    2.0: 'i will burst'
  };

  var time = Jiffy().Hm;

  void initState() {
    super.initState();
    if (widget.edit != null) {
      this._lowerValue = widget.edit.amount;
      this.time = widget.edit.time;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("How much did you eat?"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        ),
        body: Container(
            padding: EdgeInsets.all(16),
            child: Column(children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Time:',
                ),
                initialValue: this.time,
                readOnly: true,
              ),
              Expanded(
                  child: FlutterSlider(
                axis: Axis.vertical,
                rtl: true,
                values: [this._lowerValue],
                step: FlutterSliderStep(step: 0.1),
                max: 2.0,
                min: 0.25,
                tooltip: FlutterSliderTooltip(
                  format: (String str) {
                    var value = num.parse(str);
                    var rounded = (value * 4).round() / 4;
                    return this.options[rounded];
                  },
                  textStyle: TextStyle(fontSize: 17, color: Colors.white),
                  boxStyle: FlutterSliderTooltipBox(
                      decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.7))),
                  positionOffset:
                      FlutterSliderTooltipPositionOffset(left: -200),
                  alwaysShowTooltip: true,
                ),
                onDragging: (handlerIndex, lowerValue, upperValue) {
                  _lowerValue = lowerValue;
//            _upperValue = upperValue;
                  setState(() {});
                },
              )),
              RaisedButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context, new Ate(this.time, this._lowerValue));
                },
              )
            ])));
  }
}
