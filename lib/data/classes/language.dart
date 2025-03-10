class Language {
  
  final int id;
  final String name;
  final String code;
  bool? isSelected = false;

  Language(this.id, this.name, this.code, {this.isSelected = false});

  static List<Language> languageList() {
    return [
      Language(1, "English", "en"),
      Language(2, "Spanish", "es"),
      Language(3, "Portugues", "pt"),
      Language(4, "French", "fr"),
      Language(5, "Italian", "it")
    ];
  }
}