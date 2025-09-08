import 'package:get_it/get_it.dart';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';

final getIt = GetIt.instance;

class ServiceLocator {
  static Future<void> init() async {
    // Register services
    getIt.registerLazySingleton<AuthService>(() => AuthService());
    
    // Register providers
    getIt.registerLazySingleton<AuthProvider>(() => AuthProvider(getIt<AuthService>()));
  }
}
