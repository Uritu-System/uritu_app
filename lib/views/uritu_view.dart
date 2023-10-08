import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:uritu_app/constants/routes.dart';
import 'package:uritu_app/enums/menu_action.dart';
import 'package:uritu_app/model/data_model.dart';
import 'package:uritu_app/services/auth/auth_service.dart';
import 'package:http/http.dart' as http;

class UrituView extends StatefulWidget {
  const UrituView({super.key});

  @override
  State<UrituView> createState() => _UrituViewState();
}

class _UrituViewState extends State<UrituView> {
  String translated = 'Translation';

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
          const Text('Quechua (qu)'),
          const SizedBox(height: 8),
          TextField(
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
            decoration: const InputDecoration(
              hintText: 'Enter Text',
            ),
            onChanged: (text) async {
              const apiKeyTranslation = '';
              // 'AIzaSyBREdPiXiX2AF5uaGGz34U9517aaWW_kbU';
              const to = 'qu';
              const source = 'es';
              final url = Uri.https(
                'translation.googleapis.com',
                '/language/translate/v2',
              );

              final response = await http.post(url, body: {
                'q': text,
                'target': to,
                'source': source,
                'key': apiKeyTranslation,
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
          Text(
            translated,
            style: const TextStyle(
              fontSize: 36,
              color: Colors.lightBlue,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Log out'),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
