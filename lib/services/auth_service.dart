import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService instance = AuthService._();
  AuthService._();

  static const String _keyLoggedIn = 'auth_logged_in';
  static const String _keyUserEmail = 'auth_user_email';
  static const String _keyUserName = 'auth_user_name';
  static const String _keyPassword = 'auth_password_hash';
  static const String _keyCreatedAt = 'auth_created_at';
  static const String _keyUserRole = 'auth_user_role';
  static const String _keyDoctorLicense = 'auth_doctor_license';

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  // Get current user email
  Future<String?> getCurrentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }

  // Get current user name
  Future<String?> getCurrentUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  // Hash password for secure storage
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Register new user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String role,
    String? doctorLicense,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Check if user already exists
    final existingEmail = prefs.getString(_keyUserEmail);
    if (existingEmail != null) {
      return {
        'success': false,
        'message': 'An account already exists. Please login instead.',
      };
    }

    // Validate inputs
    if (email.isEmpty || !email.contains('@')) {
      return {
        'success': false,
        'message': 'Please enter a valid email address',
      };
    }

    if (password.length < 6) {
      return {
        'success': false,
        'message': 'Password must be at least 6 characters',
      };
    }

    if (name.isEmpty) {
      return {'success': false, 'message': 'Please enter your name'};
    }

    if (role == 'doctor' && (doctorLicense == null || doctorLicense.isEmpty)) {
      return {
        'success': false,
        'message': 'Please enter your doctor license number',
      };
    }

    // Store user data
    final passwordHash = _hashPassword(password);
    await prefs.setString(_keyUserEmail, email);
    await prefs.setString(_keyUserName, name);
    await prefs.setString(_keyPassword, passwordHash);
    await prefs.setString(_keyCreatedAt, DateTime.now().toIso8601String());
    await prefs.setString(_keyUserRole, role);
    if (role == 'doctor') {
      await prefs.setString(_keyDoctorLicense, doctorLicense ?? '');
    }
    await prefs.setBool(_keyLoggedIn, true);

    return {'success': true, 'message': 'Account created successfully!'};
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Get stored credentials
    final storedEmail = prefs.getString(_keyUserEmail);
    final storedPasswordHash = prefs.getString(_keyPassword);

    if (storedEmail == null || storedPasswordHash == null) {
      return {
        'success': false,
        'message': 'No account found. Please register first.',
      };
    }

    // Validate credentials
    if (email != storedEmail) {
      return {'success': false, 'message': 'Email not found'};
    }

    final passwordHash = _hashPassword(password);
    if (passwordHash != storedPasswordHash) {
      return {'success': false, 'message': 'Incorrect password'};
    }

    // Mark as logged in
    await prefs.setBool(_keyLoggedIn, true);

    return {'success': true, 'message': 'Login successful!'};
  }

  // Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, false);
  }

  // Get user info
  Future<Map<String, String?>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString(_keyUserEmail),
      'name': prefs.getString(_keyUserName),
      'createdAt': prefs.getString(_keyCreatedAt),
      'role': prefs.getString(_keyUserRole) ?? 'client',
      'license': prefs.getString(_keyDoctorLicense),
    };
  }

  Future<String> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserRole) ?? 'client';
  }

  // Check if account exists
  Future<bool> hasAccount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail) != null;
  }
}
