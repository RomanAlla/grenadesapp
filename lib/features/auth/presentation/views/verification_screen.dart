import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grenadesapp/features/auth/domain/auth_provider.dart';
import 'package:grenadesapp/features/auth/presentation/views/login_page.dart';
import 'package:grenadesapp/features/navigation/views/navigation_page.dart';
import 'package:grenadesapp/features/video/domain/usecases/get_videos_use_case.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  final GetVideosUseCase getVideosUseCase;
  final User user = FirebaseAuth.instance.currentUser!;
  VerificationScreen(
      {super.key, required this.getVideosUseCase, required User user});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  late Timer timer;
  bool _canResend = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      verifyEmail();
    });

    timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await FirebaseAuth.instance.currentUser?.reload();
      if (FirebaseAuth.instance.currentUser?.emailVerified == true) {
        timer.cancel();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => NavigationPage(
                getVideosUseCase: widget.getVideosUseCase,
              ),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future<void> verifyEmail() async {
    if (!_canResend) return;
    setState(() {
      _canResend = false;
      _isLoading = true;
    });
    try {
      await ref.read(authProvider.notifier).sendEmailVerificationLink();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Письмо для подтверждения email отправлено!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при отправке письма: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
    Future.delayed(const Duration(seconds: 60), () {
      if (mounted) setState(() => _canResend = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.mark_email_unread_rounded,
                  size: 80, color: Colors.orange),
              const SizedBox(height: 32),
              Text(
                'Подтвердите вашу почту',
                style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Мы отправили письмо для подтверждения на ваш email. Пожалуйста, перейдите по ссылке в письме, чтобы завершить регистрацию.',
                style:
                    theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const CircularProgressIndicator(color: Colors.orange)
                  : SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _canResend ? verifyEmail : null,
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(_canResend
                            ? 'Отправить письмо повторно'
                            : 'Подождите...'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
              const SizedBox(height: 24),
              const Text(
                'Проверка подтверждения происходит автоматически',
                style: TextStyle(color: Colors.white38, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => LoginPage(
                            getVideosUseCase: widget.getVideosUseCase,
                          ),
                        ),
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, color: Colors.orange),
                  label: const Text(
                    'Выйти',
                    style: TextStyle(
                        color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.orange),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
