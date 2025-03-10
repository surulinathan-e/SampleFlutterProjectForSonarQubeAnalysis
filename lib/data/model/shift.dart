import 'dart:convert';

class Shift {
  String? id;
  String? organizationId;
  String? shiftName;
  String? shiftStartDate;
  String? shiftEndDate;
  String? shiftStartTiming;
  String? shiftEndTiming;
  bool? sunday;
  bool? monday;
  bool? tuesday;
  bool? wednesday;
  bool? thursday;
  bool? friday;
  bool? saturday;

  Shift(
      this.id,
      this.organizationId,
      this.shiftName,
      this.shiftStartDate,
      this.shiftEndDate,
      this.shiftStartTiming,
      this.shiftEndTiming,
      this.sunday,
      this.monday,
      this.tuesday,
      this.wednesday,
      this.thursday,
      this.friday,
      this.saturday);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'organizationId': organizationId,
      'shiftName': shiftName,
      'shiftStartDate': shiftStartDate,
      'shiftEndDate': shiftEndDate,
      'shiftStartTiming': shiftStartTiming,
      'shiftEndTiming': shiftEndTiming,
      'sunday': sunday,
      'monday': monday,
      'tuesday': tuesday,
      'wednesday': wednesday,
      'thursday': thursday,
      'friday': friday,
      'saturday': saturday
    };
  }

  factory Shift.fromMap(Map<String, dynamic> map) {
    return Shift(
        map['id'] == null ? null : map['id'] as String,
        map['organizationId'] == null ? null : map['organizationId'] as String,
        map['shiftName'] == null ? null : map['shiftName'] as String,
        map['shiftStartDate'] == null ? null : map['shiftStartDate'] as String,
        map['shiftEndDate'] == null ? null : map['shiftEndDate'] as String,
        map['shiftStartTiming'] == null
            ? null
            : map['shiftStartTiming'] as String,
        map['shiftEndTiming'] == null ? null : map['shiftEndTiming'] as String,
        map['sunday'] == null ? false : map['sunday'] as bool,
        map['monday'] == null ? false : map['monday'] as bool,
        map['tuesday'] == null ? false : map['tuesday'] as bool,
        map['wednesday'] == null ? false : map['wednesday'] as bool,
        map['thursday'] == null ? false : map['thursday'] as bool,
        map['friday'] == null ? false : map['friday'] as bool,
        map['saturday'] == null ? false : map['saturday'] as bool);
  }

  factory Shift.fromJson(String source) =>
      Shift.fromMap(json.decode(source) as Map<String, dynamic>);
}
