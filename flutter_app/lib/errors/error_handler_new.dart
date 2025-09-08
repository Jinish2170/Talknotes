import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import 'failures.dart';

class ErrorHandler {
  static Failure handleError(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else if (error is FormatException) {
      return const ValidationFailure(
        message: 'Invalid data format',
      );
    } else if (error is TypeError) {
      return const UnknownFailure(
        message: 'Type error occurred',
      );
    } else {
      return UnknownFailure(
        message: error.toString(),
      );
    }
  }
  
  static Failure _handleDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(
          message: AppConstants.networkErrorMessage,
        );
        
      case DioExceptionType.badResponse:
        return _handleResponseError(dioError);
        
      case DioExceptionType.cancel:
        return const NetworkFailure(
          message: 'Request was cancelled',
        );
        
      case DioExceptionType.connectionError:
        return const NetworkFailure(
          message: AppConstants.networkErrorMessage,
        );
        
      case DioExceptionType.badCertificate:
        return const NetworkFailure(
          message: 'Certificate verification failed',
        );
        
      case DioExceptionType.unknown:
        return const UnknownFailure(
          message: AppConstants.unknownErrorMessage,
        );
    }
  }
  
  static Failure _handleResponseError(DioException dioError) {
    final statusCode = dioError.response?.statusCode;
    final responseData = dioError.response?.data;
    
    String message = AppConstants.serverErrorMessage;
    
    // Extract message from response if available
    if (responseData is Map<String, dynamic>) {
      message = responseData['message'] ?? 
                responseData['error'] ?? 
                message;
    }
    
    switch (statusCode) {
      case 400:
        return ValidationFailure(
          message: message,
          statusCode: statusCode,
        );
        
      case 401:
        return UnauthorizedFailure(
          message: message,
          statusCode: statusCode,
        );
        
      case 403:
        return AuthFailure(
          message: 'Access forbidden',
          statusCode: statusCode,
        );
        
      case 404:
        return ServerFailure(
          message: 'Resource not found',
          statusCode: statusCode,
        );
        
      case 422:
        return ValidationFailure(
          message: message,
          statusCode: statusCode,
        );
        
      case 500:
      case 502:
      case 503:
      case 504:
        return ServerFailure(
          message: AppConstants.serverErrorMessage,
          statusCode: statusCode,
        );
        
      default:
        return ServerFailure(
          message: message,
          statusCode: statusCode,
        );
    }
  }
  
  // Convert failure to user-friendly message
  static String getErrorMessage(Failure failure) {
    switch (failure.runtimeType) {
      case const (NetworkFailure):
        return AppConstants.networkErrorMessage;
      case const (AuthFailure):
      case const (UnauthorizedFailure):
        return 'Authentication failed. Please login again.';
      case const (AudioFailure):
        return AppConstants.audioRecordingFailed;
      case const (PermissionFailure):
        return AppConstants.audioPermissionDenied;
      case const (ValidationFailure):
        return failure.message;
      case const (ServerFailure):
        return AppConstants.serverErrorMessage;
      default:
        return failure.message.isNotEmpty 
            ? failure.message 
            : AppConstants.unknownErrorMessage;
    }
  }
}
