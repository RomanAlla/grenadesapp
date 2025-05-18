import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grenadesapp/features/auth/data/auth_service.dart';
import 'package:grenadesapp/features/auth/domain/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.read(authServiceProvider);
  return AuthNotifier(authService);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState());

  void resetState() {
    state = AuthState();
  }

  void setUser(User? user) {
    state = state.copyWith(user: user);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  Future<String?> register(
      String email, String password, String username) async {
    try {
      state = state.copyWith(isLoading: true);

      if (email.isEmpty || password.isEmpty || username.isEmpty) {
        state = state.copyWith(isLoading: false);
        return 'Пожалуйста, заполните все поля';
      }

      if (!email.contains('@') || !email.contains('.')) {
        state = state.copyWith(isLoading: false);
        return 'Неверный формат email';
      }

      if (password.length < 6) {
        state = state.copyWith(isLoading: false);
        return 'Пароль должен содержать не менее 6 символов';
      }

      final user = await _authService.register(email, password);

      if (user != null) {
        await _authService.saveUsername(user.uid, username);
        state = state.copyWith(user: user, isLoading: false);
        return null;
      } else {
        state = state.copyWith(isLoading: false);
        return 'Не удалось создать пользователя';
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<void> sendEmailVerificationLink() async {
    try {
      state = state.copyWith(isLoading: true);
      await _authService.currentUser?.sendEmailVerification();
      state = state.copyWith(isLoading: false, isEmailVerificationSent: true);
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false);
        throw Exception('Ошибка при отправке подтверждения email: $e');
      }
    }
  }

  Future<void> sendPasswordVerificationLink(String email) async {
    try {
      state = state.copyWith(isLoading: true);
      await _authService.sendPasswordVerificationLink(email);
      state = state.copyWith(isLoading: false, isPasswordResetSent: true);
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false);
        throw Exception('Ошибка при отправке подтверждения смены пароля: $e');
      }
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true);

      if (email.isEmpty || password.isEmpty) {
        state = state.copyWith(isLoading: false);
        return 'Пожалуйста, заполните все поля';
      }

      if (!email.contains('@') || !email.contains('.')) {
        state = state.copyWith(isLoading: false);
        return 'Неверный формат email';
      }

      final user = await _authService.signIn(email, password);

      if (user != null) {
        if (!user.emailVerified) {
          state = state.copyWith(isLoading: false);
          return 'Пожалуйста, подтвердите ваш email';
        }
        state = state.copyWith(user: user, isLoading: false);
        return null;
      } else {
        state = state.copyWith(isLoading: false);
        return 'Не удалось войти в аккаунт';
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> signOut() async {
    try {
      state = state.copyWith(isLoading: true);
      await _authService.signOut();
      state = state.copyWith(user: null, isLoading: false);
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return e.toString().replaceAll('Exception: ', '');
    }
  }
}
