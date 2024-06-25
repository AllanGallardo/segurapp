
// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthServices{

  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Future<User?> signUpWithEmailAndPassword(String email, String password, String nombre, String apellido, String telefono) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      print("Error al registrar usuario: $e");
      }
      return null;
    }
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      print("Error al iniciar sesión: $e");
    }
    return null;
  }
}
