import 'package:flutter/services.dart';
import 'package:googleapis/speech/v1.dart' as speech;
import 'package:googleapis_auth/auth_io.dart';
// import 'dart:developer' as developer;

Future<String> transcribeSpeech(String filePath) async {
  final clientSpeechApi = await _authenticate();
  /* ***************************** RECORDING AUDIO **************************** */
  final speechConfig = speech.RecognitionConfig(
    encoding: 'LINEAR16',
    sampleRateHertz: 16000,
    languageCode: 'es-ES',
  );
  final speechRequest = speech.RecognizeRequest(
    config: speechConfig,
    audio: speech.RecognitionAudio(content: filePath),
  );
  final response = await clientSpeechApi.speech.recognize(speechRequest);
  for (final result in response.results!) {
    for (final alternative in result.alternatives!) {
      return alternative.transcript.toString();
      // developer.log(
      //     '****************** Transcript: ${alternative.transcript} *****************');
    }
  }
  return '';
}

Future<speech.SpeechApi> _authenticate() async {
  /* ***************************** AUTHENTICATION ***************************** */
  // Load the service account key JSON file
  final jsonCredentials =
      await rootBundle.loadString('assets/uritu-system-app-172e898d6608.json');

  // Obtain the credentials using the service account key JSON file
  final accountCredentials =
      ServiceAccountCredentials.fromJson(jsonCredentials);

  // Create a new client for the Google Cloud Speech API
  final client = speech.SpeechApi(await clientViaServiceAccount(
      accountCredentials, [speech.SpeechApi.cloudPlatformScope]));

  return client;
}
