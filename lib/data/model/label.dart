import 'dart:convert';

class Label {
  String? labelId;
  String? labelName;

  Label({this.labelId, this.labelName});

  factory Label.fromMap(Map<String, dynamic> map) {
    return Label(
      labelId: map['labelId'],
      labelName: map['labelName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'labelId': labelId,
      'labelName': labelName,
    };
  }

  factory Label.fromJson(String source) =>
      Label.fromMap(json.decode(source) as Map<String, dynamic>);
}
