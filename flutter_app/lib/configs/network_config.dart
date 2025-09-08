import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';
import '../services/storage_service.dart';

class NetworkConfig {
  static Dio? _dio;
  
  static Dio get dio {
    if (_dio == null) {
      _dio = Dio();
      _configureDio(_dio!);
    }
    return _dio!;
  }
  
  static void _configureDio(Dio dio) {
    // Base configuration
    dio.options = BaseOptions(
      baseUrl: ApiEndpoints.currentBaseUrl,
      connectTimeout: AppConstants.apiTimeout,
      receiveTimeout: AppConstants.apiTimeout,
      sendTimeout: AppConstants.apiTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    
    // Add interceptors
    dio.interceptors.add(_AuthInterceptor());
    dio.interceptors.add(_ErrorInterceptor());
    
    // Add pretty logger in debug mode
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }
  
  // Special dio instance for audio upload with longer timeout
  static Dio get audioUploadDio {
    final audioDio = Dio();
    audioDio.options = BaseOptions(
      baseUrl: ApiEndpoints.currentBaseUrl,
      connectTimeout: AppConstants.longApiTimeout,
      receiveTimeout: AppConstants.longApiTimeout,
      sendTimeout: AppConstants.longApiTimeout,
      headers: {
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json',
      },
    );
    
    audioDio.interceptors.add(_AuthInterceptor());
    audioDio.interceptors.add(_ErrorInterceptor());
    
    return audioDio;
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Add authorization header if token exists
    final token = await StorageService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle token refresh on 401
    if (err.response?.statusCode == 401) {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken != null) {
        try {
          // Attempt to refresh token
          final newToken = await _refreshToken(refreshToken);
          if (newToken != null) {
            // Retry original request with new token
            err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            final response = await NetworkConfig.dio.fetch(err.requestOptions);
            return handler.resolve(response);
          }
        } catch (e) {
          // Refresh failed, logout user
          await StorageService.clearTokens();
        }
      }
    }
    handler.next(err);
  }
  
  Future<String?> _refreshToken(String refreshToken) async {
    try {
      final response = await Dio().post(
        '${ApiEndpoints.currentBaseUrl}/user/refresh-token',
        data: {'refreshToken': refreshToken},
      );
      
      if (response.statusCode == 200) {
        final newAccessToken = response.data['accessToken'];
        await StorageService.saveAccessToken(newAccessToken);
        return newAccessToken;
      }
    } catch (e) {
      // Refresh failed
    }
    return null;
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Log errors for debugging (only in debug mode)
    assert(() {
      print('API Error: ${err.message}');
      if (err.response != null) {
        print('Status Code: ${err.response!.statusCode}');
        print('Response Data: ${err.response!.data}');
      }
      return true;
    }());
    handler.next(err);
  }
}
