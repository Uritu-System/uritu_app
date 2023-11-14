import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> predictionSpeech(String encodedAudio) async {
  String url = 'http://34.71.36.238:5000/predictions';

  Map<String, dynamic> body = {'audio': encodedAudio};

  String jsonBody = json.encode(body);

  final http.Response response = await http.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: jsonBody,
  );

  if (response.statusCode == 200) {
    // Parse the response JSON.
    final Map<String, dynamic> responseBody = json.decode(response.body);
    // Get the 'transcription' field from the response JSON.
    final String transcription = responseBody['transcription'];
    return transcription;
  }

  return '';
}
