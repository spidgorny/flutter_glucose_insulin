import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

class Ate {
  TimeOfDay time;
  double amount;
  String comment;

  Ate(this.time, this.amount, {this.comment});

  Ate.fromJson(Map<String, dynamic> json) {
    List<String> parts = json['time'].split(':');
    int hh = int.parse(parts[0]);
    int mm = int.parse(parts[1]);
    this.time = TimeOfDay(hour: hh, minute: mm);
    this.amount = json['amount'];
    this.comment = json['comment'];
  }

  DateTime get dateTime => Jiffy()
      .startOf(Units.DAY)
      .add(Duration(hours: this.hour, minutes: this.minute));

  get sTime =>
      time.hour.toString().padLeft(2, '0') +
      ':' +
      time.minute.toString().padLeft(2, '0');

  Map<String, dynamic> toJson() => {
        '_type': runtimeType.toString(),
        'time': this.sTime,
        'amount': amount,
        'comment': comment,
      };

  int get hour {
    return this.time.hour;
  }

  int get minute {
    return this.time.minute;
  }

  Duration hoursSince(Ate prev) {
    if (null == prev) {
      return null;
    }
    return this.dateTime.difference(prev.dateTime);
  }
}

class CommentEntry extends Ate {
  CommentEntry(TimeOfDay time, double amount, {comment})
      : super(time, amount, comment: comment);
}

class DayData {
  DateTime date;
  List<Ate> intake;

  DayData(this.date, this.intake);
  DayData.fromJson(Map<String, dynamic> json) {
    this.date = DateTime.parse(json['date']);
    var intakeSource = json['intake'];
    print(['intakeSource', intakeSource]);
    this.intake =
        List<Ate>.from(intakeSource.map((ate) => Ate.fromJson(ate)).toList());
  }
  Map<String, dynamic> toJson() => {
        'date': this.date.toIso8601String(),
        'intake': intake.map((ate) => ate.toJson()).toList(),
      };
}
