class ApiUrls {
  // Base URLs
  static const String _devBaseUrl = 'http://10.0.2.2:3000/api';
  static const String _prodBaseUrl = 'https://gtiapi.gs1ksa.org/api';
  static const String upcHubUrl = 'https://upchub.online/api/';
  static const String gtinCheckerBaseUrl = 'https://gtiapi.gs1ksa.org/api';

  // Current environment
  // static const String currentBaseURL = _prodBaseUrl;
  static const String currentBaseURL = _devBaseUrl;

  // Existing API endpoints from the project
  static const String productDetails =
      'https://gs1.org.sa/api/foreignGtin/getGtinProductDetails';
  static const String digitalLinksRetailers =
      '${upcHubUrl}digitalLinks/retailers';
  static const String digitalLinksPackagings =
      '${upcHubUrl}digitalLinks/packagings';
  static const String digitalLinksIngredients =
      '${upcHubUrl}digitalLinks/ingredients';
  static const String digitalLinksPromotions =
      '${upcHubUrl}digitalLinks/promotions';
  static const String digitalLinksRecipes = '${upcHubUrl}digitalLinks/recipes';
  static const String digitalLinksLeaflets =
      '${upcHubUrl}digitalLinks/leaflets';
  static const String digitalLinksImages = '${upcHubUrl}digitalLinks/images';
  static const String digitalLinksVideos = '${upcHubUrl}digitalLinks/videos';

  // Auth endpoints
  static const String login = '/v1/users/login';
  static const String nfcLogin = '/v1/users/login';

  // Report endpoints
  static const String createReport = '/v1/reports';

  // Product endpoints
  static const String submitProduct = '/v1/products';
}

class ApiHeaders {
  static const String contentType = 'Content-Type';
  static const String authorization = 'Authorization';
  static const String accept = 'Accept';

  // Default headers
  static const Map<String, String> defaultHeaders = {
    contentType: 'application/json',
    accept: 'application/json',
  };
}
