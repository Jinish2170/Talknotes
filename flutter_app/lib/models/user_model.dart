// User model matching backend structure exactly
class User {
  final String? id;
  final String email;
  final String name;
  final String? authType;
  final bool isAdmin;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    this.id,
    required this.email,
    required this.name,
    this.authType = 'email',
    this.isAdmin = false,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      authType: json['auth_type'] ?? 'email',
      isAdmin: json['is_admin'] ?? false,
      isActive: json['is_active'] ?? true,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'email': email,
      'name': name,
      'auth_type': authType,
      'is_admin': isAdmin,
      'is_active': isActive,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? authType,
    bool? isAdmin,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      authType: authType ?? this.authType,
      isAdmin: isAdmin ?? this.isAdmin,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, authType: $authType, isAdmin: $isAdmin, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.email == email &&
        other.name == name &&
        other.authType == authType &&
        other.isAdmin == isAdmin &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        name.hashCode ^
        authType.hashCode ^
        isAdmin.hashCode ^
        isActive.hashCode;
  }
}

// Request models for API calls
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }
}

class RegisterRequest {
  final String email;
  final String password;
  final String name;
  final String authType;

  const RegisterRequest({
    required this.email,
    required this.password,
    required this.name,
    this.authType = 'email',
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'auth_type': authType,
    };
  }

  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      name: json['name'] ?? '',
      authType: json['auth_type'] ?? 'email',
    );
  }
}

// API Response models matching backend format exactly
class ApiResponse<T> {
  final T? result;
  final String message;
  final int status;
  final int isTokenExpire;

  const ApiResponse({
    this.result,
    required this.message,
    required this.status,
    this.isTokenExpire = 0,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, [T Function(Map<String, dynamic>)? fromJsonT]) {
    return ApiResponse<T>(
      result: json['RESULT'] != null && fromJsonT != null 
          ? fromJsonT(json['RESULT']) 
          : json['RESULT'] as T?,
      message: json['MESSAGE'] ?? '',
      status: json['STATUS'] ?? 0,
      isTokenExpire: json['IS_TOKEN_EXPIRE'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'RESULT': result,
      'MESSAGE': message,
      'STATUS': status,
      'IS_TOKEN_EXPIRE': isTokenExpire,
    };
  }

  bool get isSuccess => status == 1;
  bool get isError => status == 0;
  bool get isTokenExpired => isTokenExpire == 1;
}

class AuthResponse {
  final bool success;
  final String message;

  const AuthResponse({
    required this.success,
    required this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
    };
  }
}
