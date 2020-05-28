class Ate {
  String time;
  double amount;

  Ate(this.time, this.amount);
  Ate.fromJson(Map<String, dynamic> json) {
    this.time = json['time'];
    this.amount = json['amount'];
  }
  Map<String, dynamic> toJson() => {
        '_type': 'Ate',
        'time': time,
        'amount': amount,
      };
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
