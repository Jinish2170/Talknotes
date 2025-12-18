import 'package:get_it/get_it.dart';
import '../services/auth_service.dart';
import '../services/audio_service.dart';
import '../services/speech_to_text_service.dart';
import '../providers/auth_provider.dart';
import '../providers/recording_provider.dart';
import '../providers/notes_provider.dart';

final getIt = GetIt.instance;

class ServiceLocator {
  static Future<void> init() async {
    // Register services
    getIt.registerLazySingleton<AuthService>(() => AuthService());
    getIt.registerLazySingleton<AudioService>(() => AudioService());
    getIt.registerLazySingleton<SpeechToTextService>(
      () => SpeechToTextService(),
    );

    // Register providers
    getIt.registerLazySingleton<AuthProvider>(
      () => AuthProvider(getIt<AuthService>()),
    );
    getIt.registerLazySingleton<NotesProvider>(() => NotesProvider());
    getIt.registerLazySingleton<RecordingProvider>(() {
      final provider = RecordingProvider();
      // Set up dependency injection
      provider.setNotesProvider(getIt<NotesProvider>());
      return provider;
    });
  }
}
