import 'package:firebase_auth/firebase_auth.dart';
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
  AuthNotifier(this._authService) : super(AuthState.initial()) {}

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  Future<void> signIn(String email, String password) async {
    state = AuthState(isLoading: true, errorMessage: null);

    try {
      final user = await _authService.signIn(email, password);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> register(String email, String password, String username) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _authService.register(email, password);

      if (user == null) throw Exception("Ошибка регистрации");

      await _authService.saveUsername(user.uid, username);

      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      print('Пользователь вышел');
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      print('Ошибка при выходе: $e');
    }
  }
}
