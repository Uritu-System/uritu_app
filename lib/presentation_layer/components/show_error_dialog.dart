import 'package:flutter/material.dart';
import 'package:uritu_app/common/theme/font_theme.dart';

Future<void> showErrorDialog(BuildContext context, String text) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          'Ocurrió un error',
          style: CustomTextStyle.dialogTitle,
        ),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Ok',
              style: CustomTextStyle.dialog,
            ),
          ),
        ],
      );
    },
  );
}
