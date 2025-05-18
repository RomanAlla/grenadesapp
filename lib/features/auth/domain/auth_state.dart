import 'package:firebase_auth/firebase_auth.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final bool isEmailVerificationSent;
  final bool isPasswordResetSent;

  AuthState(
      {this.user,
      this.isLoading = false,
      this.isEmailVerificationSent = false,
      this.isPasswordResetSent = false});

  factory AuthState.initial() => AuthState();

  AuthState copyWith(
      {User? user,
      bool? isLoading,
      bool? isEmailVerificationSent,
      bool? isPasswordResetSent}) {
    return AuthState(
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        isEmailVerificationSent:
            isEmailVerificationSent ?? this.isEmailVerificationSent,
        isPasswordResetSent:
            isPasswordResetSent ?? this.isEmailVerificationSent);
  }
}
