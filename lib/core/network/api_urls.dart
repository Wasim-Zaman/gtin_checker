class ApiUrls {
  // Base URLs
  static const String _devBaseUrl = 'http://localhost:3000/api';
  static const String _prodBaseUrl = 'https://gs1.org.sa/api';

  // Current environment
  // static const String currentBaseURL = _prodBaseUrl;
  static const String currentBaseURL = _devBaseUrl;

  // Existing API endpoints from the project
  static const String productDetails =
      'https://gs1.org.sa/api/foreignGtin/getGtinProductDetails';
  static const String digitalLinksRetailers =
      'https://upchub.online/api/digitalLinks/retailers';
  static const String digitalLinksPackagings =
      'https://upchub.online/api/digitalLinks/packagings';
  static const String digitalLinksIngredients =
      'https://upchub.online/api/digitalLinks/ingredients';
  static const String digitalLinksPromotions =
      'https://upchub.online/api/digitalLinks/promotions';
  static const String digitalLinksRecipes =
      'https://upchub.online/api/digitalLinks/recipes';
  static const String digitalLinksLeaflets =
      'https://upchub.online/api/digitalLinks/leaflets';
  static const String digitalLinksImages =
      'https://upchub.online/api/digitalLinks/images';
  static const String digitalLinksVideos =
      'https://upchub.online/api/digitalLinks/videos';

  // Auth endpoints
  static const String login = '/v1/users/login';
  static const String nfcLogin = '/v1/users/login';
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
