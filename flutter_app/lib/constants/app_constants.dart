class AppConstants {
  // API Configuration - Matching your backend exactly
  static const String baseUrl = 'http://localhost:5000'; // Your backend URL
  static const String apiVersion = 'v1';
  static const String baseApiUrl = '$baseUrl/api';
  
  // API Endpoints - Exactly matching your backend routes
  // User Endpoints
  static const String userLogin = '/user/loginUser';
  static const String userRegister = '/user/registerUser';
  static const String userProfile = '/user/profile';
  static const String userVerifyOtp = '/user/verify-otp';
  static const String userResendOtp = '/user/resend-otp';
  static const String userCreateNote = '/user/createNote';
  static const String userUpdateNote = '/user/updateNote';
  static const String userDeleteNote = '/user/deleteNote';
  static const String userGetNotes = '/user/getNotes';
  static const String userSaveAudioNote = '/user/saveAudioNote';
  static const String userProcessAudioNote = '/user/processAudioNote'; // Key endpoint
  static const String userGetNoteStyles = '/user/noteStyles';
  
  // Admin Endpoints
  static const String adminCreateNoteStyle = '/admin/noteStyles';
  static const String adminUpdateNoteStyle = '/admin/noteStyles';
  static const String adminDeleteNoteStyle = '/admin/noteStyles';
  static const String adminGetNoteStyles = '/admin/noteStyles';
  static const String adminLogin = '/admin/adminLogin';
  static const String adminUserDeactivate = '/admin/userDeactivate';
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String onboardingKey = 'onboarding_completed';
  
  // Audio Configuration (matching backend limits)
  static const int maxRecordingDurationSeconds = 300; // 5 minutes
  static const int maxAudioFileSizeBytes = 50 * 1024 * 1024; // 50MB (backend limit)
  static const List<String> supportedAudioFormats = [
    'wav', 'mp3', 'mp4', 'webm', 'ogg' // From your backend audio processor
  ];
  
  // Audio Quality Settings
  static const int defaultSampleRate = 44100;
  static const int defaultBitRate = 128000;
  static const String defaultAudioFormat = 'wav';
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double mediumPadding = 12.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;
  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  
  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration defaultAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  static const Duration recordingPulseAnimation = Duration(milliseconds: 1000);
  
  // Error Messages
  static const String networkErrorMessage = 'Network connection failed. Please check your internet connection.';
  static const String serverErrorMessage = 'Server error occurred. Please try again later.';
  static const String unknownErrorMessage = 'An unknown error occurred. Please try again.';
  static const String audioPermissionDenied = 'Microphone permission is required to record audio notes.';
  static const String audioRecordingFailed = 'Failed to record audio. Please try again.';
  static const String audioProcessingFailed = 'Failed to process audio note. Please try again.';
  static const String fileTooBigError = 'Audio file is too large. Maximum size is 50MB.';
  static const String unsupportedFormatError = 'Unsupported audio format. Please use WAV, MP3, MP4, WebM, or OGG.';
  
  // Success Messages
  static const String noteCreatedSuccess = 'Note created successfully!';
  static const String noteUpdatedSuccess = 'Note updated successfully!';
  static const String noteDeletedSuccess = 'Note deleted successfully!';
  static const String audioProcessedSuccess = 'Audio note processed successfully!';
  
  // App Info
  static const String appName = 'TalkNotes';
  static const String appDescription = 'AI-Powered Voice Notes';
  static const String appVersion = '1.0.0';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration longApiTimeout = Duration(minutes: 5); // For audio processing
  
  // Note Styles (default values, will be fetched from backend)
  static const List<String> defaultNoteStyles = [
    'Professional',
    'Casual',
    'Meeting Notes',
    'Creative',
    'Technical',
  ];
}
