import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? get currentUser => _auth.currentUser;

  Future<User?> register(String email, String password) async {
    try {
      await Future.delayed(const Duration(seconds: 1)); 
      final result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      if (result.user == null) {
        throw Exception("Не удалось создать пользователя");
      }

      return result.user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('Этот email уже используется');
        case 'weak-password':
          throw Exception('Пароль слишком простой');
        case 'invalid-email':
          throw Exception('Неверный формат email');
        case 'network-request-failed':
          throw Exception('Ошибка сети. Проверьте подключение к интернету');
        case 'operation-not-allowed':
          throw Exception('Операция не разрешена. Попробуйте позже');
        default:
          throw Exception('Ошибка регистрации: ${e.message}');
      }
    } catch (e) {
      if (e.toString().contains('network error') || e.toString().contains('timeout')) {
        throw Exception('Проблема с подключением к сети. Проверьте интернет и попробуйте снова');
      }
      throw Exception('Ошибка регистрации: $e');
    }
  }

  Future<void> saveUsername(String userId, String username) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'username': username,
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Ошибка при сохранении username: $e');
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Пожалуйста, заполните все поля');
      }
      
    
      int maxRetries = 2;
      for (int i = 0; i < maxRetries; i++) {
        try {
          final result = await _auth.signInWithEmailAndPassword(
              email: email, password: password);
          return result.user;
        } catch (e) {
          if (i == maxRetries - 1 || !e.toString().contains('network error')) {
            rethrow;
          }
          await Future.delayed(Duration(seconds: 2)); 
        }
      }
      throw Exception('Не удалось войти после нескольких попыток');
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Пользователь не найден');
        case 'wrong-password':
          throw Exception('Неверный пароль');
        case 'invalid-email':
          throw Exception('Неверный формат email');
        case 'user-disabled':
          throw Exception('Аккаунт заблокирован');
        case 'network-request-failed':
          throw Exception('Ошибка сети. Проверьте подключение к интернету');
        case 'too-many-requests':
          throw Exception('Слишком много попыток входа. Попробуйте позже');
        default:
          throw Exception('Ошибка входа: ${e.message}');
      }
    } catch (e) {
      if (e.toString().contains('network error') || e.toString().contains('timeout')) {
        throw Exception('Проблема с подключением к сети. Проверьте интернет и попробуйте снова');
      }
      throw Exception('Ошибка входа: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Ошибка при выходе: $e');
    }
  }
}
