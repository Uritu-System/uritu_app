import 'package:flutter/material.dart';
import 'package:uritu_app/common/colors/color_schemes.g.dart';
import 'package:uritu_app/common/constants/routes.dart';
import 'package:uritu_app/domain_layer/auth/auth_service.dart';
import 'package:uritu_app/presentation_layer/views/login_view.dart';
import 'package:uritu_app/presentation_layer/views/register_view.dart';
import 'package:uritu_app/presentation_layer/views/uritu_view.dart';
import 'package:uritu_app/presentation_layer/views/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Uritu App',
      darkTheme: ThemeData(
        colorScheme: darkColorScheme,
        useMaterial3: true,
      ),
      // home: const RegisterView(),
      home: const HomePage(),
      // home: const LoginView(),
      // home: const VerifyEmailView(),
      initialRoute: '/',
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        urituRoute: (context) => const UrituView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                return const UrituView();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
