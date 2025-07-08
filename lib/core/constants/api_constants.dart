class ApiConstants {
  static const String baseUrl = 'https://api-gateway.thankfulwater-e8adfc7e.eastus.azurecontainerapps.io/';
  
  // Auth endpoints
  static const String signIn = 'api/v1/auth/sign-in';
  static const String signUp = 'api/v1/auth/sign-up';
  
  // Farmer endpoints (backend uses farmers instead of profiles)
  static const String farmers = 'api/v1/farmers';
  static const String profiles = 'api/v1/farmers'; // Alias for compatibility
  
  // Detection endpoints
  static const String detectionAnalyze = 'api/v1/detection/analyze';
  
  // Microservicio de detección específico
  static const String detectionServiceBaseUrl = 'https://detection-service.thankfulwater-e8adfc7e.eastus.azurecontainerapps.io/';
  static const String detectionServicePredict = 'api/v1/detections/predict';
  
  // Microservicio de cultivos
  static const String cropServiceBaseUrl = 'https://crop-service.thankfulwater-e8adfc7e.eastus.azurecontainerapps.io/';
  static const String crops = 'api/v1/crops';
  static const String diagnosis = 'api/v1/diagnosis';
  
  // Microservicio de suscripciones
  static const String subscriptionServiceBaseUrl = 'https://subscription-service.thankfulwater-e8adfc7e.eastus.azurecontainerapps.io/';
  static const String subscriptions = 'api/v1/subscriptions';
  static const String subscriptionPlans = 'api/v1/subscriptions/plans';
}
