import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grenadesapp/core/constants/app_contants.dart';
import 'package:grenadesapp/features/auth/presentation/views/login_page.dart';
import 'package:grenadesapp/features/auth/presentation/views/register_page.dart';
import 'package:grenadesapp/features/auth/presentation/views/verification_screen.dart';
import 'package:grenadesapp/features/favorites/views/favorites_page.dart';
import 'package:grenadesapp/features/navigation/views/navigation_page.dart';
import 'package:grenadesapp/features/video/data/datasources/video_remote_data_sources.dart';
import 'package:grenadesapp/features/video/domain/usecases/get_videos_use_case.dart';
import 'package:grenadesapp/features/video/data/repositories/video_repository.dart';
import 'package:grenadesapp/features/welcome/views/welcome_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:grenadesapp/firebase_options.dart';
import 'package:grenadesapp/features/video/presentation/providers/video_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:grenadesapp/features/video/providers/video_cache_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAuth.instance.setSettings(
    appVerificationDisabledForTesting: false,
    forceRecaptchaFlow: false,
  );

  FirebaseFirestore.instance.settings = Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    sslEnabled: true,
  );

  final videoRemoteDataSource =
      VideoRemoteDataSources(firestore: FirebaseFirestore.instance);
  final videoRepository = VideoRepository(dataSource: videoRemoteDataSource);
  final getVideosUseCase = GetVideosUseCase(repository: videoRepository);

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        getVideosUseCaseProvider.overrideWithValue(getVideosUseCase),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final getVideosUseCase = ref.read(getVideosUseCaseProvider);

    return MaterialApp(
      routes: {
        '/home': (context) => NavigationPage(
              getVideosUseCase: getVideosUseCase,
            ),
        '/login': (context) => LoginPage(
              getVideosUseCase: getVideosUseCase,
            ),
        '/register': (context) => RegisterPage(
              getVideosUseCase: getVideosUseCase,
            ),
        '/favorites': (context) => const FavoritesPage(),
      },
      theme: ThemeData(
        scaffoldBackgroundColor: AppTheme.background,
        canvasColor: AppTheme.background,
      ),
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error'));
          } else {
            if (snapshot.data == null) {
              return const WelcomePage();
            } else {
              if (snapshot.data!.emailVerified == true) {
                return NavigationPage(
                  getVideosUseCase: getVideosUseCase,
                );
              } else {
                return VerificationScreen(
                  user: snapshot.data!,
                  getVideosUseCase: getVideosUseCase,
                );
              }
            }
          }
        },
      ),
    );
  }
}
