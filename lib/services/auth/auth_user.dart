import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';

// immutable means this class and subclass contains immutable fields

@immutable
class AuthUser {
  final bool isEmailVerified;
  final String? email;
  const AuthUser({
    required this.email,
    required this.isEmailVerified,
  });
  // copying the firebase user to AuthUser so that the firebase user is not expose to UI directly
  factory AuthUser.fromFirebase(User user) => AuthUser(
        email: user.email,
        isEmailVerified: user.emailVerified,
      );
}
