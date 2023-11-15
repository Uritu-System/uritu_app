import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uritu_app/common/constants/stt_quechua_url';

Future<String> predictionSpeech(String encodedAudio) async {
  Map<String, dynamic> body = {'audio': encodedAudio};

  String jsonBody = json.encode(body);

  final http.Response response = await http.post(
    Uri.parse(sttQuechuaUrl),
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
