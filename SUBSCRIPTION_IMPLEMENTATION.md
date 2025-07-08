# Implementación del Sistema de Suscripciones

## Descripción General

Se ha implementado un sistema completo de suscripciones para la aplicación HidroGreen que se integra con el microservicio de suscripciones. La implementación sigue la arquitectura Clean Architecture con separación clara de responsabilidades.

## Estructura de Archivos

### Modelos de Datos
- `lib/profile/data/models/subscription_api_models.dart` - Modelos que coinciden exactamente con el swagger del microservicio

### Capa de Datos
- `lib/profile/data/datasources/subscription_data_source.dart` - Datasource para comunicación con el API
- `lib/profile/data/repositories/subscription_repository.dart` - Repositorio con validaciones básicas

### Capa de Dominio
- `lib/profile/domain/usecases/subscription_usecases.dart` - Casos de uso con lógica de negocio

### Capa de Presentación
- `lib/profile/presentation/blocs/subscription_bloc.dart` - Bloc para manejo de estado
- `lib/profile/presentation/pages/subscription_plans_page.dart` - Página para mostrar planes disponibles
- `lib/profile/presentation/pages/subscription_status_page.dart` - Página para mostrar estado de suscripción

### Configuración
- `lib/core/constants/api_constants.dart` - Constantes del API actualizadas
- `lib/core/di/service_locator.dart` - Inyección de dependencias actualizada

## Funcionalidades Implementadas

### 1. Gestión de Planes de Suscripción
- ✅ Obtener todos los planes disponibles (`GET /api/v1/subscriptions/plans`)
- ✅ Mostrar planes con información detallada (precio, características, límites)
- ✅ Interfaz visual atractiva con cards para cada plan

### 2. Creación de Suscripciones
- ✅ Crear nueva suscripción (`POST /api/v1/subscriptions`)
- ✅ Validaciones de lógica de negocio
- ✅ Manejo de referencias de pago
- ✅ Confirmación visual del proceso

### 3. Gestión de Suscripciones Existentes
- ✅ Obtener suscripción por ID (`GET /api/v1/subscriptions/{id}`)
- ✅ Obtener suscripción por usuario (`GET /api/v1/subscriptions/user/{userId}`)
- ✅ Mostrar estado detallado de la suscripción
- ✅ Información de fechas, días restantes, etc.

### 4. Renovación de Suscripciones
- ✅ Renovar suscripción (`PUT /api/v1/subscriptions/{id}/renew`)
- ✅ Cambio de tipo de suscripción
- ✅ Manejo de referencias de pago

### 5. Cancelación de Suscripciones
- ✅ Cancelar suscripción (`PUT /api/v1/subscriptions/{id}/cancel`)
- ✅ Requerir motivo de cancelación
- ✅ Validaciones de estado antes de cancelar

### 6. Funciones de Testing
- ✅ Health check del servicio (`GET /api/v1/subscriptions/test/health`)
- ✅ Test de notificaciones (`POST /api/v1/subscriptions/test/notification`)
- ✅ Test de integración con servicio de usuarios (`GET /api/v1/subscriptions/test/user/{userId}`)

## Modelos de Datos

### SubscriptionResource
```dart
class SubscriptionResource {
  final int id;
  final int userId;
  final SubscriptionType subscriptionType;
  final String subscriptionPlanName;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final bool autoRenew;
  final String? paymentReference;
  final int daysRemaining;
  final bool isActive;
  final bool isExpired;
  final String? cancellationReason;
  final DateTime? cancelledAt;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### SubscriptionPlanResource
```dart
class SubscriptionPlanResource {
  final int id;
  final SubscriptionType planType;
  final String name;
  final String description;
  final double price;
  final int durationDays;
  final int maxCrops;
  final int maxReports;
  final bool hasPrioritySupport;
  final bool hasAdvancedAnalytics;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### Enums
```dart
enum SubscriptionType {
  FREE,
  BASIC,
  PREMIUM,
  ENTERPRISE,
}

enum SubscriptionStatus {
  ACTIVE,
  EXPIRED,
  CANCELLED,
  SUSPENDED,
  PENDING_PAYMENT,
}
```

## Flujo de Uso

### 1. Ver Planes de Suscripción
```dart
// Navegar a la página de planes
Navigator.pushNamed(context, '/subscription-plans');

// El bloc automáticamente carga los planes
context.read<SubscriptionBloc>().add(LoadSubscriptionPlans());
```

### 2. Crear Suscripción
```dart
final request = CreateSubscriptionResource(
  userId: userId,
  subscriptionType: SubscriptionType.PREMIUM,
  autoRenew: true,
  paymentReference: 'PAYMENT_REF_123',
);

context.read<SubscriptionBloc>().add(CreateSubscription(request));
```

### 3. Ver Estado de Suscripción
```dart
// Navegar a la página de estado
Navigator.pushNamed(context, '/subscription-status', arguments: userId);

// El bloc carga la suscripción del usuario
context.read<SubscriptionBloc>().add(LoadSubscriptionByUserId(userId));
```

### 4. Cancelar Suscripción
```dart
context.read<SubscriptionBloc>().add(
  CancelSubscription(subscriptionId, 'Motivo de cancelación')
);
```

## Configuración del API

### URLs del Microservicio
```dart
// En api_constants.dart
static const String subscriptionServiceBaseUrl = 'https://subscription-service.thankfulwater-e8adfc7e.eastus.azurecontainerapps.io/';
static const String subscriptions = 'api/v1/subscriptions';
static const String subscriptionPlans = 'api/v1/subscriptions/plans';
```

## Inyección de Dependencias

Todas las dependencias están registradas en el `service_locator.dart`:

```dart
// Data Source
serviceLocator.registerSingleton<SubscriptionDataSource>(
  SubscriptionDataSourceImpl(serviceLocator<NetworkClient>()),
);

// Repository
serviceLocator.registerSingleton<SubscriptionRepository>(
  SubscriptionRepositoryImpl(serviceLocator<SubscriptionDataSource>()),
);

// Use Cases
serviceLocator.registerFactory<SubscriptionUseCases>(
  () => SubscriptionUseCasesImpl(serviceLocator<SubscriptionRepository>()),
);

// Bloc
serviceLocator.registerFactory<SubscriptionBloc>(() => 
  SubscriptionBloc(serviceLocator<SubscriptionUseCases>()),
);
```

## Estados del Bloc

### Events
- `LoadSubscriptionPlans` - Cargar planes disponibles
- `LoadSubscriptionByUserId` - Cargar suscripción por usuario
- `LoadSubscriptionById` - Cargar suscripción por ID
- `CreateSubscription` - Crear nueva suscripción
- `RenewSubscription` - Renovar suscripción
- `CancelSubscription` - Cancelar suscripción
- `TestNotification` - Probar notificaciones
- `TestUserService` - Probar integración con servicio de usuarios
- `HealthCheck` - Verificar salud del servicio

### States
- `SubscriptionInitial` - Estado inicial
- `SubscriptionLoading` - Cargando
- `SubscriptionPlansLoaded` - Planes cargados
- `SubscriptionLoaded` - Suscripción cargada
- `SubscriptionCreated` - Suscripción creada
- `SubscriptionRenewed` - Suscripción renovada
- `SubscriptionCancelled` - Suscripción cancelada
- `TestResultLoaded` - Resultado de test cargado
- `SubscriptionError` - Error

## Validaciones de Negocio

### Creación de Suscripciones
- Las suscripciones gratuitas no pueden tener renovación automática
- Las suscripciones pagadas requieren referencia de pago
- Validación de userId válido

### Renovación de Suscripciones
- Las suscripciones gratuitas no pueden tener referencia de pago
- Las suscripciones pagadas requieren referencia de pago
- Validación de subscriptionId válido

### Cancelación de Suscripciones
- No se puede cancelar una suscripción ya cancelada
- No se puede cancelar una suscripción expirada
- Se requiere motivo de cancelación

## Manejo de Errores

- Errores de red con reintentos
- Errores de validación con mensajes claros
- Estados de error en la UI con opciones de reintento
- Logs detallados para debugging

## Próximos Pasos

1. **Integración con Sistema de Pagos**: Conectar con pasarela de pagos real
2. **Notificaciones Push**: Implementar notificaciones de estado de suscripción
3. **Analíticas**: Agregar tracking de eventos de suscripción
4. **Cache Local**: Implementar cache para planes y estado de suscripción
5. **Offline Support**: Manejo de operaciones offline
6. **Testing**: Agregar tests unitarios y de integración

## Notas Técnicas

- La implementación usa `flutter_bloc` para manejo de estado
- Se sigue el patrón Repository para abstracción de datos
- Los modelos coinciden exactamente con el swagger del microservicio
- Se implementa inyección de dependencias con `get_it`
- La UI es responsive y sigue el diseño de la aplicación
- Se manejan todos los estados posibles del microservicio 