import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grenadesapp/core/constants/app_contants.dart';
import 'package:grenadesapp/features/auth/presentation/views/login_page.dart';
import 'package:grenadesapp/features/auth/presentation/views/register_page.dart';
import 'package:grenadesapp/features/favorites/views/favorites_page.dart';
import 'package:grenadesapp/features/navigation/views/navigation_page.dart';
import 'package:grenadesapp/features/video/data/datasources/video_remote_data_sources.dart';
import 'package:grenadesapp/features/video/domain/usecases/get_videos_use_case.dart';
import 'package:grenadesapp/features/video/data/repositories/video_repository.dart';
import 'package:grenadesapp/features/welcome/views/welcome_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:grenadesapp/firebase_options.dart';
import 'package:grenadesapp/features/video/presentation/providers/video_provider.dart';

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

  runApp(
    ProviderScope(
      overrides: [
        getVideosUseCaseProvider.overrideWithValue(getVideosUseCase),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;
    final videoRemoteDataSource = VideoRemoteDataSources(firestore: firestore);
    final videoRepository = VideoRepository(dataSource: videoRemoteDataSource);
    final getVideosUseCase = GetVideosUseCase(repository: videoRepository);

    return MaterialApp(
      routes: {
        '/register': (context) => RegisterPage(),
        '/home': (context) => NavigationPage(
              getVideosUseCase: getVideosUseCase,
            ),
        '/login': (context) => LoginPage(),
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
          if (snapshot.hasData) {
            return NavigationPage(getVideosUseCase: getVideosUseCase);
          }
          return const WelcomePage();
        },
      ),
    );
  }
}
