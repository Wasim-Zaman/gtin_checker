class Report {
  final String id;
  final String gtin;
  final DateTime dateTimeScanned;
  final String photos;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ReportUser? user;

  Report({
    required this.id,
    required this.gtin,
    required this.dateTimeScanned,
    required this.photos,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] ?? '',
      gtin: json['gtin'] ?? '',
      dateTimeScanned: DateTime.parse(json['dateTimeScanned']),
      photos: json['photos'] ?? '',
      userId: json['userId'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      user: json['user'] != null ? ReportUser.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gtin': gtin,
      'dateTimeScanned': dateTimeScanned.toIso8601String(),
      'photos': photos,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'user': user?.toJson(),
    };
  }

  // Helper to get photo URLs as a list
  List<String> get photoUrls {
    if (photos.isEmpty) return [];
    return photos.split(',').map((url) => url.trim()).toList();
  }
}

class ReportUser {
  final String id;
  final String name;
  final String email;

  ReportUser({required this.id, required this.name, required this.email});

  factory ReportUser.fromJson(Map<String, dynamic> json) {
    return ReportUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email};
  }
}

class ReportResponse {
  final int statusCode;
  final bool success;
  final String message;
  final Report data;

  ReportResponse({
    required this.statusCode,
    required this.success,
    required this.message,
    required this.data,
  });

  factory ReportResponse.fromJson(Map<String, dynamic> json) {
    return ReportResponse(
      statusCode: json['statusCode'] ?? 0,
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: Report.fromJson(json['data']),
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
