import 'package:flutter/material.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('Estas seguro de cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
