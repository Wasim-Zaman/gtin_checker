class ApiUrls {
  // Base URLs
  static const String _devBaseUrl = 'https://dev-api.example.com/api/v1';
  static const String _stagingBaseUrl = 'https://staging-api.example.com/api/v1';
  static const String _prodBaseUrl = 'https://gs1.org.sa/api';

  // Current environment
  static const String currentBaseURL = _prodBaseUrl;

  // Existing API endpoints from the project
  static const String productDetails = '/foreignGtin/getGtinProductDetails';
  static const String digitalLinksRetailers = 'https://upchub.online/api/digitalLinks/retailers';
  static const String digitalLinksPackagings = 'https://upchub.online/api/digitalLinks/packagings';
  static const String digitalLinksIngredients = 'https://upchub.online/api/digitalLinks/ingredients';
  static const String digitalLinksPromotions = 'https://upchub.online/api/digitalLinks/promotions';
  static const String digitalLinksRecipes = 'https://upchub.online/api/digitalLinks/recipes';
  static const String digitalLinksLeaflets = 'https://upchub.online/api/digitalLinks/leaflets';
  static const String digitalLinksImages = 'https://upchub.online/api/digitalLinks/images';
  static const String digitalLinksVideos = 'https://upchub.online/api/digitalLinks/videos';

  // Auth endpoints (for future use)
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';

  // User endpoints (for future use)
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile';
  static const String changePassword = '/user/change-password';

  // Static helper methods
  static String getFullUrl(String endpoint) {
    if (endpoint.startsWith('http')) {
      return endpoint;
    }
    return '$currentBaseURL$endpoint';
  }

  static String getDigitalLinksUrl(String endpoint, String barcode, {int page = 1, int pageSize = 10}) {
    const baseUrl = 'https://upchub.online/api/digitalLinks';
    return '$baseUrl/$endpoint?page=$page&pageSize=$pageSize&barcode=$barcode';
  }
}

class ApiHeaders {
  static const String contentType = 'Content-Type';
  static const String authorization = 'Authorization';
  static const String accept = 'Accept';
  static const String userAgent = 'User-Agent';
  static const String acceptLanguage = 'Accept-Language';

  // Default headers
  static const Map<String, String> defaultHeaders = {
    contentType: 'application/json',
    accept: 'application/json',
    userAgent: 'GTIN-Checker/1.0.0',
    acceptLanguage: 'en-US,en;q=0.9',
  };

  // Headers for UPCHub API
  static const Map<String, String> upcHubHeaders = {
    accept: 'application/json, text/plain, */*',
    'origin': 'https://gtrack.online',
    'referer': 'https://gtrack.online/',
    'sec-fetch-dest': 'empty',
    'sec-fetch-mode': 'cors',
    'sec-fetch-site': 'cross-site',
  };

  // Headers for image requests
  static const Map<String, String> imageHeaders = {
    accept: 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
    acceptLanguage: 'en-US,en;q=0.9',
    'referer': 'https://gs1.org.sa/',
    userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36',
    'sec-ch-ua': '"Chromium";v="136", "Google Chrome";v="136", "Not.A/Brand";v="99"',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-platform': '"macOS"',
  };
}
