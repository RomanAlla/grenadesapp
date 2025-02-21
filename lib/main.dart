import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grenadesapp/core/constants/app_contants.dart';
import 'package:grenadesapp/features/auth/presentation/views/login_page.dart';
import 'package:grenadesapp/features/auth/presentation/views/register_page.dart';
import 'package:grenadesapp/features/maps/views/maps_page.dart';
import 'package:grenadesapp/features/navigation/views/navigation_page.dart';
import 'package:grenadesapp/features/welcome/views/welcome_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:grenadesapp/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/register': (context) => RegisterPage(),
        '/home': (context) => NavigationPage(),
        '/login': (context) => LoginPage(),
      },
      theme: ThemeData(
        scaffoldBackgroundColor: AppTheme.background,
        canvasColor: AppTheme.background,
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthChecker(),
    );
  }
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        
        if (snapshot.hasData) {
          return const MapsPage();
        } else {
          return const WelcomePage();
        }
      },
    );
  }
}
