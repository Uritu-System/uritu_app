import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uritu_app/common/theme/color_schemes.dart';
import 'package:uritu_app/common/constants/routes.dart';
import 'package:uritu_app/domain_layer/auth/auth_service.dart';
import 'package:uritu_app/presentation_layer/views/login_view.dart';
import 'package:uritu_app/presentation_layer/views/register_view.dart';
import 'package:uritu_app/presentation_layer/views/uritu_quechua_spanish_view.dart';
import 'package:uritu_app/presentation_layer/views/uritu_spanish_quechua_view.dart';
import 'package:uritu_app/presentation_layer/views/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Uritu App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
        textTheme: GoogleFonts.hankenGroteskTextTheme(),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
      ),
      home: const HomePage(),
      initialRoute: '/',
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        urituSpanishRoute: (context) => const UrituSpanishView(),
        urituQuechuaRoute: (context) => const UrituQuechuaView(),
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
                return const UrituQuechuaView();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }
          default:
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [CircularProgressIndicator()],
                ),
              ),
            );
        }
      },
    );
  }
}
