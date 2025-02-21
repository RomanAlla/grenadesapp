import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? get currentUser => _auth.currentUser;

  Future<User?> register(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      if (result.user == null) {
        throw Exception("Не удалось создать пользователя");
      }

      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception('Неверный логин или пароль');
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
      final result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception('Что-то пошло не так. Попробуйте позже...');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
