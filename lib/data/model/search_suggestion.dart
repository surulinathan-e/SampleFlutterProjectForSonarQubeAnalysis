import 'dart:convert';

class SearchSuggestion {
  String? id;
  String? name;
  SearchSuggestion({this.id, this.name});
  factory SearchSuggestion.fromMap(Map<String, dynamic> map) {
    return SearchSuggestion(
      id: map['id'],
      name: map['name'],
    );
  }
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  factory SearchSuggestion.fromJson(String source) =>
      SearchSuggestion.fromMap(json.decode(source) as Map<String, dynamic>);
}
