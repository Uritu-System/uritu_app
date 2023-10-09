import 'package:flutter/material.dart';

import 'package:uritu_app/common/constants/routes.dart';
import 'package:uritu_app/common/exceptions/auth_exceptions.dart';
import 'package:uritu_app/domain_layer/auth/auth_service.dart';
import 'package:uritu_app/presentation_layer/components/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: const Text('Registro'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Ingresar correo',
            ),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: 'Ingresar contraseña',
            ),
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try {
                await AuthService.firebase()
                    .createUser(email: email, password: password);
                AuthService.firebase().sendEmailVerification();
                if (context.mounted) {
                  Navigator.of(context).pushNamed(verifyEmailRoute);
                }
              } on WeakPasswordAuthException {
                if (context.mounted) {
                  await showErrorDialog(
                    context,
                    'Contraseña débil',
                  );
                }
              } on EmailAlreadyInUseAuthException {
                if (context.mounted) {
                  await showErrorDialog(
                    context,
                    'Correo ya en uso',
                  );
                }
              } on InvalidEmailAuthException {
                if (context.mounted) {
                  await showErrorDialog(
                    context,
                    'Correo inválido',
                  );
                }
              } on GenericAuthException {
                if (context.mounted) {
                  await showErrorDialog(
                    context,
                    'Registro fallido',
                  );
                }
              }
            },
            child: const Text('Registrarse'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                loginRoute,
                (route) => false,
              );
            },
            child: const Text('Ya registrado? Inicia sesión aquí!'),
          )
        ],
      ),
    );
  }
}
