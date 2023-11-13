import 'package:flutter/services.dart';
import 'package:googleapis/speech/v1.dart' as speech;
import 'package:googleapis_auth/auth_io.dart';

Future<String> transcribeSpeech(String encodedAudio) async {
  final clientSpeechApi = await _authenticate();
  /* ***************************** RECORDING AUDIO **************************** */
  // audio config with encoding format, sample rate hertz and language code
  final speechConfig = speech.RecognitionConfig(
    encoding: 'LINEAR16',
    sampleRateHertz: 16000,
    languageCode: 'es-ES',
  );
  // the request need the config for the audio and the audio
  final speechRequest = speech.RecognizeRequest(
    config: speechConfig,
    audio: speech.RecognitionAudio(content: encodedAudio),
  );

  // save the response of the client speech api
  final response = await clientSpeechApi.speech.recognize(speechRequest);

  // return the transcription
  for (final result in response.results!) {
    for (final alternative in result.alternatives!) {
      return alternative.transcript.toString();
    }
  }

  // if transcription is null then return ''
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
