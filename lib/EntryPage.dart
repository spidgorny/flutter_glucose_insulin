import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';

import 'DayData.dart';

class EntryPage extends StatefulWidget {
  final Ate edit;
  final bool withMealSize;

  EntryPage({this.edit, this.withMealSize = false});

  @override
  _EntryPageState createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  double sliderValue = 1;
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

  var time = TimeOfDay.now();
  String comment = '';

  TextEditingController _timeController = new TextEditingController();
  TextEditingController _commentController = new TextEditingController();

  void initState() {
    super.initState();
    if (widget.edit != null) {
      this.time = widget.edit.time;
      this.sliderValue = widget.edit.amount;
      this.comment = widget.edit.comment;
    }
  }

  @override
  Widget build(BuildContext context) {
    _timeController.text = this.time.toString();
    _commentController.text = this.comment;
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
                controller: _timeController,
                decoration: InputDecoration(
                  labelText: 'Time:',
                ),
                readOnly: true,
                onTap: () async {
                  var selectedTime = await showTimePicker(
                    initialTime: this.time,
                    context: context,
                  );
                  if (selectedTime != null) {
                    setState(() {
                      this.time = selectedTime;
                    });
                  }
                },
              ),
              widget.withMealSize
                  ? Expanded(
                      child: FlutterSlider(
                      axis: Axis.vertical,
                      rtl: true,
                      values: [this.sliderValue],
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
                        sliderValue = lowerValue;
//            _upperValue = upperValue;
                        setState(() {});
                      },
                    ))
                  : Container(),
              Expanded(
                  child: TextField(
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
//                    border: InputBorder.none,
                    hintText: 'Comment'),
                controller: _commentController,
                onChanged: (String newVal) {
                  this.comment = newVal;
                },
                onEditingComplete: () {},
              )),
              RaisedButton(
                child: Text('OK'),
                onPressed: () {
                  var result;
                  if (widget.withMealSize) {
                    result = new Ate(this.time, this.sliderValue);
                  } else {
                    result =
                        new CommentEntry(this.time, 0, comment: this.comment);
                  }
                  Navigator.pop(context, result);
                },
              )
            ])));
  }
}
