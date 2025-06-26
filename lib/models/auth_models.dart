class User {
  final String id;
  final String email;
  final String name;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String role;
  final bool isActive;
  final String? profilePicture;
  final String? address;
  final String? dateOfBirth;
  final bool isNfcEnabled;
  final String? nfcNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.firstName,
    this.lastName,
    this.phone,
    required this.role,
    required this.isActive,
    this.profilePicture,
    this.address,
    this.dateOfBirth,
    required this.isNfcEnabled,
    this.nfcNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String,
      isActive: json['isActive'] as bool,
      profilePicture: json['profilePicture'] as String?,
      address: json['address'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      isNfcEnabled: json['isNfcEnabled'] as bool,
      nfcNumber: json['nfcNumber'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'role': role,
      'isActive': isActive,
      'profilePicture': profilePicture,
      'address': address,
      'dateOfBirth': dateOfBirth,
      'isNfcEnabled': isNfcEnabled,
      'nfcNumber': nfcNumber,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class LoginData {
  final User user;
  final String token;
  final String loginMethod;

  LoginData({
    required this.user,
    required this.token,
    required this.loginMethod,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
      loginMethod: json['loginMethod'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'user': user.toJson(), 'token': token, 'loginMethod': loginMethod};
  }
}

class LoginResponse {
  final int statusCode;
  final bool success;
  final String message;
  final LoginData data;

  LoginResponse({
    required this.statusCode,
    required this.success,
    required this.message,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      statusCode: json['statusCode'] as int,
      success: json['success'] as bool,
      message: json['message'] as String,
      data: LoginData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }
}
