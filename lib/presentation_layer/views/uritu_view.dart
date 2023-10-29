import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uritu_app/common/constants/path_audio.dart';
import 'package:uritu_app/common/constants/routes.dart';
import 'package:uritu_app/common/enums/menu_action.dart';
import 'package:uritu_app/common/theme/font_theme.dart';
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

  Future initRecorder() async {
    final statusMicrophone = await Permission.microphone.status;
    if (!statusMicrophone.isGranted) {
      await Permission.microphone.request();
    }
    await Permission.storage.request();

    await recorder.openRecorder();
    isRecorderReady = true;
    recorder.setSubscriptionDuration(
      const Duration(milliseconds: 500),
    );
  }

  Future record() async {
    if (!isRecorderReady) return;

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

    final audioFile = File(pathToAudio);
    final base64EncodecAudio = base64Encode(await audioFile.readAsBytes());

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
      body: Container(
        color: Colors.amber,
        padding: EdgeInsets.all(30.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  /* ************************************************************************** */
                  /*                                PRIMER IDIOMA                               */
                  /* ************************************************************************** */
                  const Text(
                    'Español',
                    style: CustomTextStyle.language,
                    textAlign: TextAlign.left,
                  ),
                  TextFormField(
                    controller: _textEditingController,
                    style: CustomTextStyle.textNormal,
                    maxLines: null,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      hintText: 'Traducción',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (text) async {
                      String textUpdate = await translateQuechuaToSpanish(
                          _textEditingController.text);
                      setState(() {
                        _textTranslated = textUpdate;
                      });
                    },
                  ),
                  /* ************************************************************************** */
                  /*                                     FIN                                    */
                  /* ************************************************************************** */
                ],
              ),

              Column(
                children: [
                  /* ************************************************************************** */
                  /*                               SEGUNDO IDIOMA                               */
                  /* ************************************************************************** */
                  const Text(
                    'Quechua',
                    style: CustomTextStyle.language,
                    textAlign: TextAlign.left,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          _textTranslated,
                          style: CustomTextStyle.textNormal,
                          textAlign: TextAlign.center,
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
                  /* ************************************************************************** */
                  /*                                     FIN                                    */
                  /* ************************************************************************** */
                ],
              ),
              // const SizedBox(
              //   height: 20,
              // ),
              Column(
                children: [
                  /* ************************************************************************** */
                  /*                                TERCERA PARTE                               */
                  /* ************************************************************************** */
                  ElevatedButton(
                    style: FilledButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(24),
                    ),
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
                  /* ************************************************************************** */
                  /*                                     FIN                                    */
                  /* ************************************************************************** */
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
