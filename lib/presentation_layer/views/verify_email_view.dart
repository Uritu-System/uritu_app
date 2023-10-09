import 'package:flutter/material.dart';
import 'package:uritu_app/common/constants/routes.dart';
import 'package:uritu_app/domain_layer/auth/auth_service.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: const Text('Verificación'),
      ),
      body: Column(
        children: [
          const Text(
              "Le hemos enviado una verificación por correo electrónico. Ábralo para verificar su cuenta."),
          const Text(
              "Si aún no ha recibido un correo electrónico de verificación, presione el botón a continuación"),
          TextButton(
            onPressed: () async {
              AuthService.firebase().sendEmailVerification();
            },
            child: const Text('Enviar correo de verificación'),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().logOut();
              if (context.mounted) {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(registerRoute, (route) => false);
              }
            },
            child: const Text('Volver'),
          )
        ],
      ),
    );
  }
}
