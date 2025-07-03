class ProductSubmitRequest {
  final String gtin;
  final String? gpcCategoryCode;
  final String? gpcCategoryName;
  final String? brandName;
  final String? brandLanguage;
  final String? productDescription;
  final String? productDescLanguage;
  final String? productImageUrl;
  final String? productImageLanguage;
  final String? unitCode;
  final String? unitValue;
  final String? productName;
  final String? companyName;
  final String? moName;
  final String? licenceKey;
  final String? licenceType;
  final String? type;
  final String? countryOfSaleName;
  final String? companyRegistrationDate;
  final String? gcpGLNID;
  final String? contactWebsite;
  final String? formattedAddress;
  final DateTime dateTimeScanned;

  ProductSubmitRequest({
    required this.gtin,
    this.gpcCategoryCode,
    this.gpcCategoryName,
    this.brandName,
    this.brandLanguage,
    this.productDescription,
    this.productDescLanguage,
    this.productImageUrl,
    this.productImageLanguage,
    this.unitCode,
    this.unitValue,
    this.productName,
    this.companyName,
    this.moName,
    this.licenceKey,
    this.licenceType,
    this.type,
    this.countryOfSaleName,
    this.companyRegistrationDate,
    this.gcpGLNID,
    this.contactWebsite,
    this.formattedAddress,
    required this.dateTimeScanned,
  });

  Map<String, dynamic> toJson() {
    return {
      'gtin': gtin,
      'gpcCategoryCode': gpcCategoryCode,
      'gpcCategoryName': gpcCategoryName,
      'brandName': brandName,
      'brandLanguage': brandLanguage ?? 'en',
      'productDescription': productDescription,
      'productDescLanguage': productDescLanguage ?? 'en',
      'productImageUrl': productImageUrl,
      'productImageLanguage': productImageLanguage ?? 'en',
      'unitCode': unitCode,
      'unitValue': unitValue,
      'productName': productName,
      'companyName': companyName,
      'moName': moName,
      'licenceKey': licenceKey,
      'licenceType': licenceType,
      'type': type ?? 'global',
      'countryOfSaleName': countryOfSaleName,
      'companyRegistrationDate': companyRegistrationDate,
      'gcpGLNID': gcpGLNID,
      'contactWebsite': contactWebsite,
      'formattedAddress': formattedAddress,
    };
  }
}

class ProductSubmitResponse {
  final bool success;
  final String message;
  final ProductSubmitData? data;

  ProductSubmitResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ProductSubmitResponse.fromJson(Map<String, dynamic> json) {
    return ProductSubmitResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? ProductSubmitData.fromJson(json['data'])
          : null,
    );
  }
}

class ProductSubmitData {
  final String id;
  final String gtin;
  final DateTime dateTimeScanned;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductSubmitData({
    required this.id,
    required this.gtin,
    required this.dateTimeScanned,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductSubmitData.fromJson(Map<String, dynamic> json) {
    return ProductSubmitData(
      id: json['id'] ?? '',
      gtin: json['gtin'] ?? '',
      dateTimeScanned: DateTime.parse(json['dateTimeScanned']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
