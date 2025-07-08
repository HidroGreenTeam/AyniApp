# Sistema de Detección Híbrida - Ayni

## Descripción

El sistema de detección híbrida de Ayni permite detectar enfermedades de plantas usando dos modos diferentes:

1. **Detección Online**: Utiliza un microservicio Azure con IA avanzada
2. **Detección Local**: Utiliza un modelo TensorFlow Lite en el dispositivo
3. **Detección Automática**: Selecciona automáticamente el mejor modo disponible

## Configuración

### Microservicio Online
- **URL**: `https://detection-service.thankfulwater-e8adfc7e.eastus.azurecontainerapps.io/`
- **Endpoint**: `/api/v1/detections/predict`
- **Método**: POST
- **Formato**: multipart/form-data
- **Parámetro**: `file` (imagen JPEG)

### Respuesta del Microservicio
```json
{
  "predicted_class": "miner",
  "confidence": 0.9999994039535522,
  "disease_detected": true,
  "requires_treatment": true
}
```

### Enfermedades Detectadas
- `miner` → Minador de hojas
- `phoma` → Mancha foliar por Phoma
- `redspider` → Ácaros rojos
- `rust` → Roya foliar
- `nodisease` → Sin enfermedad

## Funcionalidades

### 1. Selección de Modo de Detección
- **Página**: `DetectionModeSelectionPage`
- **Opciones**:
  - Online: Microservicio Azure con mayor precisión
  - Local: TensorFlow Lite para uso offline
  - Automático: Selección inteligente basada en conectividad

### 2. Detección Híbrida
- **Servicio**: `HybridDetectionService`
- **Características**:
  - Verifica conectividad automáticamente
  - Intenta detección online primero
  - Fallback a detección local si falla
  - Manejo de errores robusto

### 3. Interfaz de Usuario
- **Indicadores visuales** del modo de detección
- **Mensajes informativos** durante el procesamiento
- **Recomendaciones específicas** según el tipo de enfermedad
- **Historial de detecciones** con detalles

## Archivos Principales

### Servicios
- `lib/detection/services/hybrid_detection_service.dart` - Servicio principal
- `lib/detection/services/plant_disease_classifier.dart` - Clasificador local
- `lib/core/network/network_client.dart` - Cliente HTTP

### Páginas
- `lib/detection/presentation/pages/detection_mode_selection_page.dart` - Selección de modo
- `lib/camera/presentation/pages/camera_page.dart` - Página de cámara

### Widgets
- `lib/camera/presentation/widgets/welcome_widget.dart` - Pantalla de bienvenida
- `lib/camera/presentation/widgets/processing_widget.dart` - Indicador de procesamiento

## Uso

### Para el Usuario Final
1. Abrir la aplicación
2. Ir a "Detectar Enfermedades"
3. Seleccionar modo de detección:
   - **Online**: Para máxima precisión (requiere internet)
   - **Local**: Para uso offline
   - **Automático**: Para mejor experiencia
4. Tomar foto o seleccionar de galería
5. Esperar el análisis
6. Revisar resultados y recomendaciones

### Para Desarrolladores
```dart
// Inicializar servicio
final detectionService = HybridDetectionService();
await detectionService.initialize();

// Detección automática
final result = await detectionService.detectDisease(imageFile);

// Detección forzada online
final onlineResult = await detectionService.detectOnlineOnly(imageFile);

// Detección forzada local
final localResult = await detectionService.detectLocalOnly(imageFile);
```

## Ventajas del Sistema Híbrido

### Detección Online
- ✅ Mayor precisión
- ✅ Modelo actualizado constantemente
- ✅ Análisis más detallado
- ✅ Detección de necesidad de tratamiento
- ❌ Requiere conexión a internet
- ❌ Dependiente del servidor

### Detección Local
- ✅ Funciona sin internet
- ✅ Privacidad total
- ✅ Análisis rápido
- ✅ No depende de servidores externos
- ❌ Menor precisión
- ❌ Modelo limitado

### Detección Automática
- ✅ Mejor experiencia de usuario
- ✅ Optimiza precisión y velocidad
- ✅ Fallback automático
- ✅ Funciona en cualquier condición

## Configuración de Red

### Constantes de API
```dart
// lib/core/constants/api_constants.dart
static const String detectionServiceBaseUrl = 'https://detection-service.thankfulwater-e8adfc7e.eastus.azurecontainerapps.io/';
static const String detectionServicePredict = 'api/v1/detections/predict';
```

### Manejo de Errores
- Timeout de conexión
- Errores de red
- Fallback automático
- Mensajes informativos al usuario

## Pruebas

Para probar el microservicio:
```bash
curl -X 'POST' \
  'https://detection-service.thankfulwater-e8adfc7e.eastus.azurecontainerapps.io/api/v1/detections/predict' \
  -H 'accept: application/json' \
  -H 'Content-Type: multipart/form-data' \
  -F 'file=@imagen.jpg;type=image/jpeg'
```

## Notas Técnicas

- El sistema usa `http` package para peticiones multipart
- Manejo de imágenes con `image_picker`
- Almacenamiento local con `shared_preferences`
- Verificación de conectividad con `connectivity_plus`
- Modelo TensorFlow Lite para detección local 