import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

class DayEntry {
  TimeOfDay time;
  double amount;
  String comment;

  DayEntry(this.time, this.amount, {this.comment});

  DayEntry.fromJson(Map<String, dynamic> json) {
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

  Duration hoursSince(DayEntry prev) {
    if (null == prev) {
      return null;
    }
    return this.dateTime.difference(prev.dateTime);
  }
}

class Ate extends DayEntry {
  @override
  Ate(time, amount, {comment}) : super(time, amount, comment: comment);

  Ate.fromJson(Map<String, dynamic> json) : super(TimeOfDay.now(), 0.0) {
    List<String> parts = json['time'].split(':');
    int hh = int.parse(parts[0]);
    int mm = int.parse(parts[1]);
    this.time = TimeOfDay(hour: hh, minute: mm);
    this.amount = json['amount'];
    this.comment = json['comment'];
  }
}

class CommentEntry extends DayEntry {
  CommentEntry(TimeOfDay time, double amount, {comment})
      : super(time, amount, comment: comment);

  CommentEntry.fromJson(Map<String, dynamic> json)
      : super(TimeOfDay.now(), 0.0) {
    List<String> parts = json['time'].split(':');
    int hh = int.parse(parts[0]);
    int mm = int.parse(parts[1]);
    this.time = TimeOfDay(hour: hh, minute: mm);
//    this.amount = json['amount'];
    this.comment = json['comment'];
  }
}

class DayData {
  DateTime date;
  List<DayEntry> intake;

  DayData(this.date, this.intake);

  DayData.fromJson(Map<String, dynamic> json) {
    this.date = DateTime.parse(json['date']);
    var intakeSource = json['intake'];
    print(['intakeSource', intakeSource]);
    this.intake = List<DayEntry>.from(intakeSource
        .map((ate) => ate['_type'] == 'CommentEntry'
            ? CommentEntry.fromJson(ate)
            : Ate.fromJson(ate))
        .toList());
  }

  List<CommentEntry> get onlyComments => List<CommentEntry>.from(
      this.intake.where((element) => element is CommentEntry));

  Map<String, dynamic> toJson() => {
        'date': this.date.toIso8601String(),
        'intake': intake.map((ate) => ate.toJson()).toList(),
      };

  List<Ate> get onlyAte {
    var onlyAte = List<Ate>.from(this.intake.where((DayEntry element) {
//      print(['where', element is Ate]);
      return element is Ate;
    }));
    return onlyAte;
  }
}
