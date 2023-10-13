import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uritu_app/common/constants/routes.dart';
import 'package:uritu_app/common/enums/menu_action.dart';
import 'package:uritu_app/domain_layer/auth/auth_service.dart';
import 'package:uritu_app/domain_layer/translation/translation.dart';
import 'package:uritu_app/presentation_layer/components/show_log_out_dialog.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:uritu_app/domain_layer/stt/stt.dart';
import 'package:path/path.dart' as p;

class UrituView extends StatefulWidget {
  const UrituView({super.key});

  @override
  State<UrituView> createState() => _UrituViewState();
}

class _UrituViewState extends State<UrituView> {
  String _textTranslated = 'Tikray';
  final flutterTts = FlutterTts();
  final recorder = FlutterSoundRecorder();
  bool isRecorderReady = false;

  final _textEditingController = TextEditingController();

  void _updateTextField(String newText) {
    setState(() {
      _textEditingController.text = newText;
    });
  }

  speak(String text) async {
    await flutterTts.setLanguage("es-ES");
    await flutterTts.setPitch(1); //0.5 to 1.5
    await flutterTts.speak(text);
  }

  @override
  void initState() {
    super.initState();
    // requestPermission();
    initRecorder();
    _textEditingController.addListener(() async {
      String textUpdate =
          await translateQuechuaToSpanish(_textEditingController.text);
      setState(() {
        _textTranslated = textUpdate;
      });
    });
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    _textEditingController.dispose();

    super.dispose();
  }

  // void requestPermission() async {
  //   // final statusExternalStorage = await Permission.manageExternalStorage.request();
  //   final statusExternalStorage = await Permission.manageExternalStorage.status;

  //   if (!statusExternalStorage.isGranted) {
  //     await Permission.manageExternalStorage.request();
  //   }

  //   // if (statusExternalStorage != PermissionStatus.granted) {
  //   //   throw 'Microphone permission not granted';
  //   // }

  //   // final statusStorage = await Permission.storage.request();
  //   final statusStorage = await Permission.storage.status;
  //   if (!statusStorage.isGranted) {
  //     await Permission.storage.request();
  //   }
  //   // if (statusStorage != PermissionStatus.granted) {
  //   //   throw 'Microphone permission not granted';
  //   // }
  // }

  Future initRecorder() async {
    final statusMicrophone = await Permission.microphone.status;
    if (!statusMicrophone.isGranted) {
      await Permission.microphone.request();
    }
    await Permission.storage.request();

    // final statusMicrophone = await Permission.microphone.request();
    // if (statusMicrophone != PermissionStatus.granted) {
    //   throw 'Microphone permission not granted';
    // }

    await recorder.openRecorder();
    isRecorderReady = true;
    recorder.setSubscriptionDuration(
      const Duration(milliseconds: 500),
    );
  }

  Future record() async {
    if (!isRecorderReady) return;
    const pathToAudio = '/storage/emulated/0/Download/audio.wav';
    if (await File(pathToAudio).exists()) {
      // If the file exists, delete it
      await File(pathToAudio).delete();
    }
    // const pathToAudio = '/audio.wav';
    Directory directory = Directory(p.dirname(pathToAudio));
    if (!directory.existsSync()) {
      directory.createSync();
    }
    await recorder.startRecorder(
      toFile: pathToAudio,
      codec: Codec.pcm16WAV,
    );
  }

  Future stop() async {
    if (!isRecorderReady) return;
    await recorder.stopRecorder();
    const pathToAudio = '/storage/emulated/0/Download/audio.wav';
    // const pathToAudio = '/audio.wav';

    final audioFile = File(pathToAudio);
    final base64EncodecAudio = base64Encode(await audioFile.readAsBytes());

    _updateTextField(await transcribeSpeech(base64EncodecAudio));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 2,
        title: const Text('Uritu'),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    await AuthService.firebase().logOut();
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        loginRoute,
                        (_) => false,
                      );
                    }
                  }
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Cerrar Sesión'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<RecordingDisposition>(
              stream: recorder.onProgress,
              builder: (context, snapshot) {
                final duration =
                    snapshot.hasData ? snapshot.data!.duration : Duration.zero;
                String twoDigits(int n) => n.toString().padLeft(2, '0');
                final twoDigitMinutes =
                    twoDigits(duration.inMinutes.remainder(60));
                final twoDigitSeconds =
                    twoDigits(duration.inSeconds.remainder(60));
                return Text(
                  '$twoDigitMinutes:$twoDigitSeconds',
                  style: const TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            const SizedBox(
              height: 32,
            ),
            const Text('Español'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _textEditingController,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                hintText: 'Traducción',
              ),
              onChanged: (text) async {
                String textUpdate = await translateQuechuaToSpanish(
                    _textEditingController.text);
                setState(() {
                  _textTranslated = textUpdate;
                });
              },
            ),
            const Divider(
              height: 32,
            ),
            const Text('Quechua'),
            Text(
              _textTranslated,
              style: const TextStyle(
                fontSize: 36,
                color: Colors.lightBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton.filled(
              onPressed: () => speak(_textTranslated),
              icon: const Icon(Icons.volume_up),
            ),
            const Text(
              'Press the button to start speech recognition:',
            ),
            ElevatedButton(
              child: Icon(
                recorder.isRecording ? Icons.stop : Icons.mic,
                size: 50,
              ),
              onPressed: () async {
                if (recorder.isRecording) {
                  await stop();
                } else {
                  await record();
                }
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}
