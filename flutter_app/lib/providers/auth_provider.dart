import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  
  AuthState _state = AuthState.initial;
  User? _user;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  AuthState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _state == AuthState.authenticated && _user != null;

  AuthProvider(this._authService) {
    _checkAuthStatus();
  }

  /// Check if user is already logged in
  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await StorageService.isLoggedIn();
      if (isLoggedIn) {
        // Try to get user data from storage
        final userData = await StorageService.getUserData();
        if (userData != null) {
          _user = userData;
          _state = AuthState.authenticated;
        } else {
          _state = AuthState.unauthenticated;
        }
      } else {
        _state = AuthState.unauthenticated;
      }
    } catch (e) {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  /// Register new user
  Future<bool> register({
    required String email,
    required String name,
    required String password,
  }) async {
    // Clear previous errors
    _clearError();
    
    // Validate inputs
    if (!_authService.isValidEmail(email)) {
      _setError('Please enter a valid email address');
      return false;
    }
    
    if (!_authService.isValidName(name)) {
      _setError('Name must be between 2-50 characters');
      return false;
    }
    
    if (!_authService.isValidPassword(password)) {
      _setError(_authService.getPasswordValidationMessage());
      return false;
    }

    _setLoading(true);

    try {
      final request = RegisterRequest(
        email: email.trim().toLowerCase(),
        name: name.trim(),
        password: password,
        authType: 'email',
      );

      final response = await _authService.registerUser(request);
      
      if (response.isSuccess) {
        // Registration successful
        _setSuccess('Registration successful! Please login with your credentials.');
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    // Clear previous errors
    _clearError();
    
    // Validate inputs
    if (!_authService.isValidEmail(email)) {
      _setError('Please enter a valid email address');
      return false;
    }
    
    if (password.isEmpty) {
      _setError('Password is required');
      return false;
    }

    _setLoading(true);

    try {
      final request = LoginRequest(
        email: email.trim().toLowerCase(),
        password: password,
      );

      final response = await _authService.loginUser(request);
      
      if (response.isSuccess) {
        // Create user object (backend doesn't return user data, just success message)
        final user = User(
          email: email.trim().toLowerCase(),
          name: '', // Will be updated when we fetch profile
          authType: 'email',
        );
        
        // Save authentication state
        await StorageService.saveUserData(user);
        await StorageService.setLoggedIn(true);
        
        _user = user;
        _state = AuthState.authenticated;
        _setLoading(false);
        notifyListeners();
        
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Logout user
  Future<void> logout() async {
    _setLoading(true);

    try {
      // Clear stored data
      await StorageService.clearUserData();
      await StorageService.setLoggedIn(false);
      
      // Reset state
      _user = null;
      _state = AuthState.unauthenticated;
      _clearError();
    } catch (e) {
      _setError('Failed to logout: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? name,
    String? email,
  }) async {
    if (_user == null) {
      _setError('User not logged in');
      return false;
    }

    _setLoading(true);

    try {
      final updateData = <String, dynamic>{};
      
      if (name != null && name.isNotEmpty && _authService.isValidName(name)) {
        updateData['name'] = name.trim();
      }
      
      if (email != null && email.isNotEmpty && _authService.isValidEmail(email)) {
        updateData['email'] = email.trim().toLowerCase();
      }

      if (updateData.isEmpty) {
        _setError('No valid updates provided');
        return false;
      }

      final response = await _authService.updateUser(_user!.id ?? '', updateData);
      
      if (response.isSuccess) {
        // Update local user data
        _user = _user!.copyWith(
          name: name ?? _user!.name,
          email: email ?? _user!.email,
        );
        
        await StorageService.saveUserData(_user!);
        notifyListeners();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Clear error message
  void clearError() {
    _clearError();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _state = AuthState.loading;
    }
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = AuthState.error;
    _isLoading = false;
    notifyListeners();
  }

  void _setSuccess(String message) {
    _errorMessage = message; // Can be used for success messages too
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = _user != null ? AuthState.authenticated : AuthState.unauthenticated;
    }
    notifyListeners();
  }
}
