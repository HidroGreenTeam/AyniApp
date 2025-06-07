class ApiConstants {
  static const String baseUrl = 'https://ayni-backend-mono-d5akeuepdsgrauaa.canadacentral-01.azurewebsites.net/';
  
  // Auth endpoints
  static const String signIn = 'api/v1/auth/sign-in';
  static const String signUp = 'api/v1/auth/sign-up';
  
  // Farmer endpoints (backend uses farmers instead of profiles)
  static const String farmers = 'api/v1/farmers';
  static const String profiles = 'api/v1/farmers'; // Alias for compatibility
}
