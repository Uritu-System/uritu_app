import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:uritu_app/common/constants/routes.dart';
import 'package:uritu_app/common/constants/translator_key.dart';
import 'package:uritu_app/common/enums/menu_action.dart';
import 'package:uritu_app/data_layer/data_model.dart';
import 'package:uritu_app/domain_layer/auth/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:uritu_app/presentation_layer/components/show_log_out_dialog.dart';
import 'package:flutter_tts/flutter_tts.dart';

class UrituView extends StatefulWidget {
  const UrituView({super.key});

  @override
  State<UrituView> createState() => _UrituViewState();
}

class _UrituViewState extends State<UrituView> {
  String translated = 'Translation';
  final FlutterTts flutterTts = FlutterTts();
  final TextEditingController textEditingController = TextEditingController();

  speak(String text) async {
    await flutterTts.setLanguage("es-ES");
    await flutterTts.setPitch(1); //0.5 to 1.5
    await flutterTts.speak(text);
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
                  child: Text('Log Out'),
                ),
              ];
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Quechua'),
          const SizedBox(height: 8),
          TextFormField(
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
            decoration: const InputDecoration(
              hintText: 'Enter Text',
            ),
            onChanged: (text) async {
              final url = Uri.https(
                'translation.googleapis.com',
                '/language/translate/v2',
              );

              final response = await http.post(url, body: {
                'q': text,
                'target': quechuaCodeTranslation,
                'source': spanishCodeTranslation,
                'key': '',
                //TODO: Change Apikeytranslations
                // descomenta lo de abajo
                // 'key': cloudTranslationApiKey,
              });

              var translationJson =
                  jsonDecode(response.body)['data']['translations'] as List;

              List<Translations> allTranslations = translationJson
                  .map((translations) => Translations.fromJson(translations))
                  .toList();

              if (response.statusCode == 200) {
                setState(() {
                  translated = allTranslations.first.toString();
                });
              }
            },
          ),
          const Divider(
            height: 32,
          ),
          const Text('Español'),
          Text(
            translated,
            style: const TextStyle(
              fontSize: 36,
              color: Colors.lightBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextFormField(
            controller: textEditingController,
          ),
          TextButton(
            onPressed: () => speak(textEditingController.text),
            child: const Text('Text to speech'),
          ),
        ],
      ),
    );
  }
}
