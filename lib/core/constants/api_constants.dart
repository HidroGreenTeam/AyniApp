class ApiConstants {
  static const String baseUrl = 'https://api-gateway.thankfulwater-e8adfc7e.eastus.azurecontainerapps.io/';
  
  // Auth endpoints
  static const String signIn = 'api/v1/auth/sign-in';
  static const String signUp = 'api/v1/auth/sign-up';
  
  // Farmer endpoints (backend uses farmers instead of profiles)
  static const String farmers = 'api/v1/farmers';
  static const String profiles = 'api/v1/farmers'; // Alias for compatibility
  
  // Detection endpoints (legacy)
  static const String detectionAnalyze = 'api/v1/detection/analyze';
  
  // Microservicio de detección de enfermedades de plantas
  static const String detectionServiceBaseUrl = 'https://detection-service.thankfulwater-e8adfc7e.eastus.azurecontainerapps.io/';
  static const String detectionServicePredict = 'api/v1/detections/predict';
  static const String detectionServiceDiagnose = 'api/v1/detections/diagnose';
  static const String detectionServiceDetail = 'api/v1/detections/detail';
  static const String detectionServiceByCrop = 'api/v1/detections/crop';
  static const String detectionServiceStatistics = 'api/v1/detections/statistics';
  static const String detectionServiceByFarmer = 'api/v1/detections';
  static const String detectionServiceHealth = 'api/v1/detections/health/api/v1/health';
  
  // Microservicio de tratamientos HidroBots
  static const String treatmentServiceBaseUrl = 'https://treatment-service.thankfulwater-e8adfc7e.eastus.azurecontainerapps.io/';
  static const String treatmentSteps = 'api/v1/treatments/steps';
  static const String treatmentsByTreatmentId = 'api/v1/treatments';
  static const String treatmentStepSkip = 'api/v1/treatments/steps';
  static const String treatmentStepComplete = 'api/v1/treatments/steps';
  static const String treatmentById = 'api/v1/treatments';
  static const String treatmentStepsWithReminders = 'api/v1/treatments/steps/reminders';
  static const String treatmentOverdueSteps = 'api/v1/treatments/steps/overdue';
  static const String treatmentsByProfile = 'api/v1/treatments/profile';
  static const String treatmentOverdue = 'api/v1/treatments/overdue';
  static const String treatmentsByCrop = 'api/v1/treatments/crop';
  
  // Microservicio de cultivos
  static const String cropServiceBaseUrl = 'https://crop-service.thankfulwater-e8adfc7e.eastus.azurecontainerapps.io/';
  static const String crops = 'api/v1/crops';
  static const String diagnosis = 'api/v1/diagnosis';
  
  // Microservicio de suscripciones
  static const String subscriptionServiceBaseUrl = 'https://subscription-service.thankfulwater-e8adfc7e.eastus.azurecontainerapps.io/';
  static const String subscriptions = 'api/v1/subscriptions';
  static const String subscriptionPlans = 'api/v1/subscriptions/plans';
}
