import 'package:flutter/material.dart';
import 'package:uritu_app/common/constants/routes.dart';
import 'package:uritu_app/common/exceptions/auth_exceptions.dart';
import 'package:uritu_app/common/theme/font_theme.dart';
import 'package:uritu_app/domain_layer/auth/auth_service.dart';
import 'package:uritu_app/presentation_layer/components/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
        elevation: 25,
        title: const Text(
          'Inicio de Sesión',
          style: CustomTextStyle.appBarStyle,
        ),
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
        child: Column(
          children: [
            const SizedBox(
              height: 32,
            ),
            TextField(
              controller: _email,
              enableSuggestions: false,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                icon: Icon(Icons.mail),
                labelText: 'Correo',
                hintText: 'Ingresar correo',
              ),
              style: CustomTextStyle.textField,
            ),
            const SizedBox(
              height: 12,
            ),
            TextField(
              controller: _password,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(
                icon: Icon(Icons.password),
                labelText: 'Contraseña',
                hintText: 'Ingresar contraseña',
              ),
              style: CustomTextStyle.textField,
            ),
            const SizedBox(
              height: 18,
            ),
            TextButton(
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;
                try {
                  await AuthService.firebase()
                      .logIn(email: email, password: password);

                  final user = AuthService.firebase().currentUser;
                  if (user?.isEmailVerified ?? false) {
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        urituRoute,
                        (route) => false,
                      );
                    }
                  } else {
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        verifyEmailRoute,
                        (route) => false,
                      );
                    }
                  }
                } on UserNotFoundAuthException {
                  if (context.mounted) {
                    await showErrorDialog(
                      context,
                      'Usuario no encontrado.',
                    );
                  }
                } on WrongPasswordAuthException {
                  if (context.mounted) {
                    await showErrorDialog(
                      context,
                      'Credenciale incorrectas',
                    );
                  }
                } on GenericAuthException {
                  if (context.mounted) {
                    await showErrorDialog(
                      context,
                      'Error de Autenticación',
                    );
                  }
                }
              },
              child: const Text(
                'Iniciar Sesión',
                style: CustomTextStyle.button,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  registerRoute,
                  (route) => false,
                );
              },
              child: const Text(
                'Registrarse',
                style: CustomTextStyle.button,
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }
}
