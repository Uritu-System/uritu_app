class Translations {
  String? translatedText;

  Translations(this.translatedText);

  factory Translations.fromJson(dynamic json) {
    return Translations(json['translatedText'] as String);
  }

  @override
  String toString() {
    return '$translatedText';
  }
}
