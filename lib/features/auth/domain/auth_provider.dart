import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grenadesapp/features/auth/data/auth_service.dart';
import 'package:grenadesapp/features/auth/domain/auth_state.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.read(authServiceProvider);
  return AuthNotifier(authService);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  AuthNotifier(this._authService) : super(AuthState.initial());

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  Future<void> signIn(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Пожалуйста, заполните все поля',
      );
      return;
    }

    state = AuthState(isLoading: true, errorMessage: null);

    try {
      final user = await _authService.signIn(email, password);
      if (user != null) {
        state =
            state.copyWith(user: user, isLoading: false, errorMessage: null);
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Ошибка входа: пользователь не найден',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> register(String email, String password, String username) async {
    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Пожалуйста, заполните все поля',
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _authService.register(email, password);

      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Ошибка регистрации: пользователь не создан',
        );
        return;
      }

      await _authService.saveUsername(user.uid, username);
      state = state.copyWith(user: user, isLoading: false, errorMessage: null);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _authService.signOut();
      state = AuthState.initial();

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Ошибка при выходе из аккаунта',
      );
    }
  }
}
