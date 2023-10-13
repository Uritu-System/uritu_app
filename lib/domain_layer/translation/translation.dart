import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uritu_app/common/constants/translator_key.dart';
import 'package:uritu_app/data_layer/data_model.dart';

Future<String> translateQuechuaToSpanish(String stringTranslate) async {
  final url = Uri.https(
    'translation.googleapis.com',
    '/language/translate/v2',
  );
  final response = await http.post(url, body: {
    'q': stringTranslate,
    'target': quechuaCodeTranslation,
    'source': spanishCodeTranslation,
    'key': cloudTranslationApiKey,
  });

  var translationJson =
      jsonDecode(response.body)['data']['translations'] as List;

  List<Translations> allTranslations = translationJson
      .map((translations) => Translations.fromJson(translations))
      .toList();
  if (response.statusCode == 200) {
    return allTranslations.first.toString();
  } else {
    return '';
  }
}
