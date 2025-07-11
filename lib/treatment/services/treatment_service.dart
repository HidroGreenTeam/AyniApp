import 'package:ayni/treatment/data/models/treatment_models.dart';

/// Servicio para gestionar tratamientos y generar planes de tratamiento
class TreatmentService {
  
  /// Genera pasos de tratamiento recomendados basados en la enfermedad detectada
  List<CreateTreatmentStepRequest> generateTreatmentSteps(String diseaseType) {
    switch (diseaseType.toLowerCase()) {
      case 'rust':
      case 'leaf_rust':
        return _generateRustTreatmentSteps();
      case 'miner':
      case 'leaf_miner':
        return _generateMinerTreatmentSteps();
      case 'phoma':
      case 'phoma_leaf_spot':
        return _generatePhomaTreatmentSteps();
      case 'redspider':
      case 'red_spider_mite':
        return _generateRedSpiderTreatmentSteps();
      default:
        return _generateGenericTreatmentSteps();
    }
  }

  /// Genera el título del tratamiento basado en la enfermedad
  String generateTreatmentTitle(String diseaseType) {
    switch (diseaseType.toLowerCase()) {
      case 'rust':
      case 'leaf_rust':
        return 'Tratamiento para Roya Foliar';
      case 'miner':
      case 'leaf_miner':
        return 'Tratamiento para Minador de Hojas';
      case 'phoma':
      case 'phoma_leaf_spot':
        return 'Tratamiento para Mancha Foliar por Phoma';
      case 'redspider':
      case 'red_spider_mite':
        return 'Tratamiento para Ácaros Rojos';
      default:
        return 'Tratamiento General para Enfermedad de Plantas';
    }
  }

  /// Genera la descripción del tratamiento
  String generateTreatmentDescription(String diseaseType, double confidence) {
    final confidencePercent = (confidence * 100).toStringAsFixed(1);
    
    switch (diseaseType.toLowerCase()) {
      case 'rust':
      case 'leaf_rust':
        return 'Plan de tratamiento para combatir la roya foliar detectada con $confidencePercent% de confianza. Incluye aplicación de fungicidas y medidas preventivas.';
      case 'miner':
      case 'leaf_miner':
        return 'Plan de tratamiento para controlar el minador de hojas detectado con $confidencePercent% de confianza. Incluye aplicación de insecticidas y eliminación de hojas afectadas.';
      case 'phoma':
      case 'phoma_leaf_spot':
        return 'Plan de tratamiento para la mancha foliar por Phoma detectada con $confidencePercent% de confianza. Incluye fungicidas y mejora de condiciones de humedad.';
      case 'redspider':
      case 'red_spider_mite':
        return 'Plan de tratamiento para ácaros rojos detectados con $confidencePercent% de confianza. Incluye acaricidas y control de humedad ambiental.';
      default:
        return 'Plan de tratamiento general para la enfermedad detectada con $confidencePercent% de confianza.';
    }
  }

  List<CreateTreatmentStepRequest> _generateRustTreatmentSteps() {
    final now = DateTime.now();
    return [
      CreateTreatmentStepRequest(
        name: 'Inspección inicial',
        description: 'Examinar todas las plantas para identificar el alcance de la infección por roya.',
        scheduledDate: now.add(const Duration(hours: 2)),
        hasReminder: true,
        reminderMinutesBefore: 30,
      ),
      CreateTreatmentStepRequest(
        name: 'Eliminar hojas afectadas',
        description: 'Remover y destruir todas las hojas con síntomas de roya para evitar propagación.',
        scheduledDate: now.add(const Duration(hours: 4)),
        hasReminder: true,
        reminderMinutesBefore: 60,
      ),
      CreateTreatmentStepRequest(
        name: 'Aplicar fungicida a base de cobre',
        description: 'Aplicar fungicida a base de cobre en toda la planta, especialmente en hojas nuevas.',
        scheduledDate: now.add(const Duration(days: 1)),
        hasReminder: true,
        reminderMinutesBefore: 120,
      ),
      CreateTreatmentStepRequest(
        name: 'Mejorar ventilación',
        description: 'Asegurar buena circulación de aire alrededor de las plantas.',
        scheduledDate: now.add(const Duration(days: 1, hours: 2)),
        hasReminder: false,
      ),
      CreateTreatmentStepRequest(
        name: 'Segunda aplicación de fungicida',
        description: 'Aplicar segunda dosis de fungicida según las instrucciones del producto.',
        scheduledDate: now.add(const Duration(days: 7)),
        hasReminder: true,
        reminderMinutesBefore: 180,
      ),
      CreateTreatmentStepRequest(
        name: 'Monitoreo de seguimiento',
        description: 'Inspeccionar las plantas para verificar la efectividad del tratamiento.',
        scheduledDate: now.add(const Duration(days: 14)),
        hasReminder: true,
        reminderMinutesBefore: 60,
      ),
    ];
  }

  List<CreateTreatmentStepRequest> _generateMinerTreatmentSteps() {
    final now = DateTime.now();
    return [
      CreateTreatmentStepRequest(
        name: 'Identificar hojas infestadas',
        description: 'Localizar todas las hojas con túneles característicos del minador.',
        scheduledDate: now.add(const Duration(hours: 1)),
        hasReminder: true,
        reminderMinutesBefore: 30,
      ),
      CreateTreatmentStepRequest(
        name: 'Remover hojas afectadas',
        description: 'Cortar y destruir todas las hojas con signos de minador para interrumpir el ciclo.',
        scheduledDate: now.add(const Duration(hours: 3)),
        hasReminder: true,
        reminderMinutesBefore: 60,
      ),
      CreateTreatmentStepRequest(
        name: 'Aplicar insecticida sistémico',
        description: 'Aplicar insecticida sistémico específico para minadores de hojas.',
        scheduledDate: now.add(const Duration(days: 1)),
        hasReminder: true,
        reminderMinutesBefore: 120,
      ),
      CreateTreatmentStepRequest(
        name: 'Colocar trampas adhesivas',
        description: 'Instalar trampas adhesivas amarillas para capturar adultos.',
        scheduledDate: now.add(const Duration(days: 1, hours: 4)),
        hasReminder: false,
      ),
      CreateTreatmentStepRequest(
        name: 'Monitoreo semanal',
        description: 'Revisar semanalmente para detectar nuevas infestaciones.',
        scheduledDate: now.add(const Duration(days: 7)),
        hasReminder: true,
        reminderMinutesBefore: 60,
      ),
    ];
  }

  List<CreateTreatmentStepRequest> _generatePhomaTreatmentSteps() {
    final now = DateTime.now();
    return [
      CreateTreatmentStepRequest(
        name: 'Evaluación de condiciones',
        description: 'Evaluar condiciones de humedad y ventilación que favorecen el hongo.',
        scheduledDate: now.add(const Duration(hours: 2)),
        hasReminder: true,
        reminderMinutesBefore: 30,
      ),
      CreateTreatmentStepRequest(
        name: 'Ajustar riego',
        description: 'Cambiar método de riego para evitar mojar las hojas (riego por goteo).',
        scheduledDate: now.add(const Duration(hours: 6)),
        hasReminder: true,
        reminderMinutesBefore: 60,
      ),
      CreateTreatmentStepRequest(
        name: 'Aplicar fungicida preventivo',
        description: 'Aplicar fungicida preventivo específico para hongos foliares.',
        scheduledDate: now.add(const Duration(days: 1)),
        hasReminder: true,
        reminderMinutesBefore: 120,
      ),
      CreateTreatmentStepRequest(
        name: 'Mejorar drenaje',
        description: 'Asegurar buen drenaje del suelo para evitar encharcamiento.',
        scheduledDate: now.add(const Duration(days: 2)),
        hasReminder: false,
      ),
      CreateTreatmentStepRequest(
        name: 'Control de seguimiento',
        description: 'Monitorear la evolución de las manchas foliares.',
        scheduledDate: now.add(const Duration(days: 10)),
        hasReminder: true,
        reminderMinutesBefore: 60,
      ),
    ];
  }

  List<CreateTreatmentStepRequest> _generateRedSpiderTreatmentSteps() {
    final now = DateTime.now();
    return [
      CreateTreatmentStepRequest(
        name: 'Aumentar humedad ambiental',
        description: 'Incrementar la humedad relativa alrededor de las plantas al 60-70%.',
        scheduledDate: now.add(const Duration(hours: 1)),
        hasReminder: true,
        reminderMinutesBefore: 30,
      ),
      CreateTreatmentStepRequest(
        name: 'Lavado con agua',
        description: 'Rociar las plantas con agua para eliminar ácaros visibles.',
        scheduledDate: now.add(const Duration(hours: 4)),
        hasReminder: true,
        reminderMinutesBefore: 60,
      ),
      CreateTreatmentStepRequest(
        name: 'Aplicar jabón insecticida',
        description: 'Aplicar solución de jabón insecticida en toda la planta.',
        scheduledDate: now.add(const Duration(days: 1)),
        hasReminder: true,
        reminderMinutesBefore: 120,
      ),
      CreateTreatmentStepRequest(
        name: 'Control biológico',
        description: 'Introducir ácaros depredadores benéficos si están disponibles.',
        scheduledDate: now.add(const Duration(days: 3)),
        hasReminder: false,
      ),
      CreateTreatmentStepRequest(
        name: 'Revisión de efectividad',
        description: 'Inspeccionar plantas para verificar reducción de población de ácaros.',
        scheduledDate: now.add(const Duration(days: 7)),
        hasReminder: true,
        reminderMinutesBefore: 60,
      ),
    ];
  }

  List<CreateTreatmentStepRequest> _generateGenericTreatmentSteps() {
    final now = DateTime.now();
    return [
      CreateTreatmentStepRequest(
        name: 'Evaluación general',
        description: 'Evaluar el estado general de la planta y síntomas observados.',
        scheduledDate: now.add(const Duration(hours: 2)),
        hasReminder: true,
        reminderMinutesBefore: 30,
      ),
      CreateTreatmentStepRequest(
        name: 'Aislamiento preventivo',
        description: 'Aislar la planta afectada para evitar propagación a plantas sanas.',
        scheduledDate: now.add(const Duration(hours: 4)),
        hasReminder: true,
        reminderMinutesBefore: 60,
      ),
      CreateTreatmentStepRequest(
        name: 'Aplicación de tratamiento',
        description: 'Aplicar tratamiento apropiado según recomendaciones de especialista.',
        scheduledDate: now.add(const Duration(days: 1)),
        hasReminder: true,
        reminderMinutesBefore: 120,
      ),
      CreateTreatmentStepRequest(
        name: 'Monitoreo de progreso',
        description: 'Revisar progreso del tratamiento y ajustar si es necesario.',
        scheduledDate: now.add(const Duration(days: 7)),
        hasReminder: true,
        reminderMinutesBefore: 60,
      ),
    ];
  }
} 