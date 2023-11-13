import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uritu_app/common/constants/path_audio.dart';
import 'package:uritu_app/common/constants/routes.dart';
import 'package:uritu_app/common/enums/menu_action.dart';
import 'package:uritu_app/common/theme/color_schemes.dart';
import 'package:uritu_app/common/theme/font_theme.dart';
import 'package:uritu_app/domain_layer/auth/auth_service.dart';
import 'package:uritu_app/domain_layer/translation/translation_spanish.dart';
import 'package:uritu_app/presentation_layer/components/show_log_out_dialog.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:uritu_app/domain_layer/stt/stt.dart';
import 'package:path/path.dart' as p;

class UrituSpanishView extends StatefulWidget {
  const UrituSpanishView({super.key});

  @override
  State<UrituSpanishView> createState() => _UrituSpanishViewState();
}

class _UrituSpanishViewState extends State<UrituSpanishView> {
  // text translated
  String _textTranslated = 'Tikray';
  // initialice fluttertts
  final flutterTts = FlutterTts();
  // initialice recorder
  final recorder = FlutterSoundRecorder();
  // initialice if recorder is ready
  bool isRecorderReady = false;
  // initialice text editing controller
  final _textEditingController = TextEditingController();

  Color _updateButtonColor(BuildContext context) {
    // update Colors depending on theme
    Color color;
    if (Theme.of(context).brightness == Brightness.light) {
      color = lightColorScheme.secondary;
    } else {
      color = darkColorScheme.secondary;
    }
    return color;
  }

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
    initRecorder();
    // add listener to text editing controller
    _textEditingController.addListener(() async {
      String textUpdate = await translateSpanish(_textEditingController.text);
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

  Future initRecorder() async {
    // permission mic request
    final statusMicrophone = await Permission.microphone.status;
    if (!statusMicrophone.isGranted) {
      await Permission.microphone.request();
    }
    // permission storage request
    await Permission.storage.request();
    // open recorder
    await recorder.openRecorder();
    isRecorderReady = true;
    recorder.setSubscriptionDuration(
      const Duration(milliseconds: 500),
    );
  }

  Future record() async {
    if (!isRecorderReady) return;
    // if the file doesn't exist create the file
    Directory directory = Directory(p.dirname(pathToAudio));
    if (!directory.existsSync()) {
      directory.createSync();
    }
    // start recorder
    await recorder.startRecorder(
      toFile: pathToAudio,
      codec: Codec.pcm16WAV,
    );
  }

  Future stop() async {
    if (!isRecorderReady) return;
    // stop recorder
    await recorder.stopRecorder();
    // get the file of the audio
    final audioFile = File(pathToAudio);
    // encode the audio to the request
    final base64EncodecAudio = base64Encode(await audioFile.readAsBytes());
    // update textfield
    _updateTextField(await transcribeSpeech(base64EncodecAudio));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 25,
        title: const Text(
          'Uritu',
          style: CustomTextStyle.appBarStyle,
        ),
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
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            /* ************************************************************************** */
            /*                               Select Language                              */
            /* ************************************************************************** */
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Expanded(
                  child: Center(
                    child: Text(
                      "Español",
                      style: CustomTextStyle.language,
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.15,
                  height: MediaQuery.of(context).size.height * 0.05,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1000.0),
                    color: _updateButtonColor(context),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          urituQuechuaRoute, (route) => false);
                    },
                    icon: const Icon(
                      Icons.autorenew,
                    ),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      "Quechua",
                      style: CustomTextStyle.language,
                    ),
                  ),
                ),
              ],
            ),
            /* ************************************************************************** */
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            /* ************************************************************************** */
            /*                                   Spanish                                  */
            /* ************************************************************************** */
            Container(
              padding: const EdgeInsets.all(25.0),
              margin: const EdgeInsets.symmetric(horizontal: 15.0),
              child: TextField(
                textAlign: TextAlign.center,
                minLines: 1,
                maxLines: 7,
                textCapitalization: TextCapitalization.sentences,
                controller: _textEditingController,
                style: CustomTextStyle.textField,
                decoration: const InputDecoration(
                  hintText: 'Traducción',
                  border: OutlineInputBorder(),
                ),
                onChanged: (text) async {
                  String textUpdate =
                      await translateSpanish(_textEditingController.text);
                  setState(() {
                    _textTranslated = textUpdate;
                  });
                },
              ),
            ),
            /* ************************************************************************** */
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            /* ************************************************************************** */
            /*                                   Quechua                                  */
            /* ************************************************************************** */
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 35.0),
              child: Container(
                padding: const EdgeInsets.all(25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          _textTranslated,
                          style: CustomTextStyle.textNormal,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => speak(_textTranslated),
                      icon: const Icon(
                        Icons.volume_up,
                        size: 36,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            /* ************************************************************************** */
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            /* ************************************************************************** */
            /*                                 Mic Button                                 */
            /* ************************************************************************** */
            Column(
              children: [
                ElevatedButton(
                  style: FilledButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(24),
                  ),
                  child: Icon(
                    recorder.isRecording ? Icons.stop : Icons.mic,
                    size: 40,
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
                StreamBuilder<RecordingDisposition>(
                  stream: recorder.onProgress,
                  builder: (context, snapshot) {
                    final duration = snapshot.hasData
                        ? snapshot.data!.duration
                        : Duration.zero;
                    String twoDigits(int n) => n.toString().padLeft(2, '0');
                    final twoDigitMinutes =
                        twoDigits(duration.inMinutes.remainder(60));
                    final twoDigitSeconds =
                        twoDigits(duration.inSeconds.remainder(60));
                    return Text(
                      '$twoDigitMinutes:$twoDigitSeconds',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
