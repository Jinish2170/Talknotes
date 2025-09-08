import 'package:dio/dio.dart';
import '../configs/network_config.dart';
import '../models/user_model.dart';
import '../constants/app_constants.dart';

class AuthService {
  final Dio _dio = NetworkConfig.dio;

  /// Register new user
  /// Backend expects: { email, password, name, auth_type }
  /// Backend returns: { RESULT: { success, message }, MESSAGE, STATUS, IS_TOKEN_EXPIRE }
  Future<ApiResponse<AuthResponse>> registerUser(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        AppConstants.userRegister,
        data: request.toJson(),
      );

      // Parse the response according to backend format
      final apiResponse = ApiResponse<AuthResponse>.fromJson(
        response.data,
        (json) => AuthResponse.fromJson(json),
      );

      return apiResponse;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  /// Login user
  /// Backend expects: { email, password }
  /// Backend returns: { RESULT: { success, message }, MESSAGE, STATUS, IS_TOKEN_EXPIRE }
  Future<ApiResponse<AuthResponse>> loginUser(LoginRequest request) async {
    try {
      final response = await _dio.post(
        AppConstants.userLogin,
        data: request.toJson(),
      );

      // Parse the response according to backend format
      final apiResponse = ApiResponse<AuthResponse>.fromJson(
        response.data,
        (json) => AuthResponse.fromJson(json),
      );

      return apiResponse;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  /// Update user information
  /// Backend expects: { email?, name?, ... } in request body
  /// URL format: /user/updateUser/:userId
  Future<ApiResponse<AuthResponse>> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      final response = await _dio.put(
        '${AppConstants.userProfile}/$userId',
        data: userData,
      );

      final apiResponse = ApiResponse<AuthResponse>.fromJson(
        response.data,
        (json) => AuthResponse.fromJson(json),
      );

      return apiResponse;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Update failed: ${e.toString()}');
    }
  }

  /// Validate email format
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate password according to backend requirements
  /// Backend requires: min 8 chars, uppercase, lowercase, number, special character
  bool isValidPassword(String password) {
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return passwordRegex.hasMatch(password);
  }

  /// Get password validation message
  String getPasswordValidationMessage() {
    return 'Password must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, one number, and one special character';
  }

  /// Validate name (non-empty, reasonable length)
  bool isValidName(String name) {
    return name.isNotEmpty && name.trim().length >= 2 && name.trim().length <= 50;
  }

  /// Handle Dio errors and convert to readable messages
  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      
      case DioExceptionType.badResponse:
        if (e.response?.data != null) {
          // Try to parse backend error message
          try {
            final errorData = e.response!.data;
            if (errorData is Map<String, dynamic> && errorData['MESSAGE'] != null) {
              return errorData['MESSAGE'];
            }
          } catch (_) {
            // If parsing fails, use status code message
          }
        }
        
        switch (e.response?.statusCode) {
          case 400:
            return 'Invalid request. Please check your input.';
          case 401:
            return 'Authentication failed. Please check your credentials.';
          case 403:
            return 'Access forbidden.';
          case 404:
            return 'Service not found.';
          case 500:
            return 'Server error. Please try again later.';
          default:
            return 'Something went wrong. Please try again.';
        }
      
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      
      case DioExceptionType.unknown:
        if (e.error.toString().contains('SocketException')) {
          return 'No internet connection. Please check your network.';
        }
        return 'Network error occurred. Please try again.';
      
      default:
        return 'An unexpected error occurred.';
    }
  }
}
