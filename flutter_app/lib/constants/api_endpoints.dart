import 'app_constants.dart';

class ApiEndpoints {
  // Base Configuration
  static const String production = 'https://api.talknotes.com';
  static const String staging = 'https://staging-api.talknotes.com';
  static const String development = 'http://localhost:5000';
  
  // Current Environment
  static const String currentBaseUrl = development; // Change for different environments
  
  // Complete API URLs
  static String get userLogin => '$currentBaseUrl${AppConstants.userLogin}';
  static String get userRegister => '$currentBaseUrl${AppConstants.userRegister}';
  static String get userProfile => '$currentBaseUrl${AppConstants.userProfile}';
  static String get userVerifyOtp => '$currentBaseUrl${AppConstants.userVerifyOtp}';
  static String get userResendOtp => '$currentBaseUrl${AppConstants.userResendOtp}';
  static String get userCreateNote => '$currentBaseUrl${AppConstants.userCreateNote}';
  static String get userUpdateNote => '$currentBaseUrl${AppConstants.userUpdateNote}';
  static String get userDeleteNote => '$currentBaseUrl${AppConstants.userDeleteNote}';
  static String get userGetNotes => '$currentBaseUrl${AppConstants.userGetNotes}';
  static String get userGetNote => '$currentBaseUrl${AppConstants.userGetNote}';
  static String get userProcessAudioNote => '$currentBaseUrl${AppConstants.userProcessAudioNote}';
  static String get userGetNoteStyles => '$currentBaseUrl${AppConstants.userGetNoteStyles}';
  
  // Admin URLs
  static String get adminCreateNoteStyle => '$currentBaseUrl${AppConstants.adminCreateNoteStyle}';
  static String get adminUpdateNoteStyle => '$currentBaseUrl${AppConstants.adminUpdateNoteStyle}';
  static String get adminDeleteNoteStyle => '$currentBaseUrl${AppConstants.adminDeleteNoteStyle}';
  static String get adminGetAllUsers => '$currentBaseUrl${AppConstants.adminGetAllUsers}';
  static String get adminGetAllNotes => '$currentBaseUrl${AppConstants.adminGetAllNotes}';
  
  // Dynamic URLs with parameters
  static String getUserNoteById(String noteId) => '$currentBaseUrl${AppConstants.userGetNote}/$noteId';
  static String updateNoteById(String noteId) => '$currentBaseUrl${AppConstants.userUpdateNote}/$noteId';
  static String deleteNoteById(String noteId) => '$currentBaseUrl${AppConstants.userDeleteNote}/$noteId';
  static String updateNoteStyleById(String styleId) => '$currentBaseUrl${AppConstants.adminUpdateNoteStyle}/$styleId';
  static String deleteNoteStyleById(String styleId) => '$currentBaseUrl${AppConstants.adminDeleteNoteStyle}/$styleId';
}
