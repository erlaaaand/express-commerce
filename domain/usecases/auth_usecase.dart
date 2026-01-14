import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

class AuthUseCase {
  final AuthRepository _authRepository;

  AuthUseCase(this._authRepository);

  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
  }) async {
    if (username.length < 3) {
      throw Exception('Username harus minimal 3 karakter');
    }

    if (password.length < 6) {
      throw Exception('Password harus minimal 6 karakter');
    }

    if (!_isValidEmail(email)) {
      throw Exception('Format email tidak valid');
    }

    return await _authRepository.register(
      username: username,
      email: email,
      password: password,
    );
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email dan password tidak boleh kosong');
    }

    if (!_isValidEmail(email)) {
      throw Exception('Format email tidak valid');
    }

    return await _authRepository.login(
      email: email,
      password: password,
    );
  }

  Future<UserModel> getProfile() async {
    return await _authRepository.getProfile();
  }

  Future<void> logout() async {
    await _authRepository.logout();
  }

  Future<bool> isLoggedIn() async {
    return await _authRepository.isLoggedIn();
  }

  Future<Map<String, dynamic>?> getStoredUserData() async {
    return await _authRepository.getStoredUserData();
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool isValidUsername(String username) {
    if (username.length < 3 || username.length > 20) {
      return false;
    }
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    return usernameRegex.hasMatch(username);
  }

  bool isStrongPassword(String password) {
    if (password.length < 6) return false;
    
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    
    final hasLetter = password.contains(RegExp(r'[a-zA-Z]'));
    
    return hasNumber && hasLetter;
  }

  PasswordStrength getPasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.none;
    if (password.length < 6) return PasswordStrength.weak;

    int strength = 0;
    
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    if (strength <= 2) return PasswordStrength.weak;
    if (strength <= 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }
}

enum PasswordStrength {
  none,
  weak,
  medium,
  strong,
}