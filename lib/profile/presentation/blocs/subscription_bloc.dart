import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/subscription_api_models.dart';
import '../../domain/usecases/subscription_usecases.dart';

// Events
abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

class LoadSubscriptionPlans extends SubscriptionEvent {}

class LoadSubscriptionByUserId extends SubscriptionEvent {
  final int userId;

  const LoadSubscriptionByUserId(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadSubscriptionById extends SubscriptionEvent {
  final int subscriptionId;

  const LoadSubscriptionById(this.subscriptionId);

  @override
  List<Object?> get props => [subscriptionId];
}

class CreateSubscription extends SubscriptionEvent {
  final CreateSubscriptionResource request;

  const CreateSubscription(this.request);

  @override
  List<Object?> get props => [request];
}

class ActivateSubscription extends SubscriptionEvent {
  final int subscriptionId;
  final ActivateSubscriptionResource request;

  const ActivateSubscription(this.subscriptionId, this.request);

  @override
  List<Object?> get props => [subscriptionId, request];
}

class RenewSubscription extends SubscriptionEvent {
  final int subscriptionId;
  final SubscriptionType newSubscriptionType;
  final String? paymentReference;

  const RenewSubscription(this.subscriptionId, this.newSubscriptionType, this.paymentReference);

  @override
  List<Object?> get props => [subscriptionId, newSubscriptionType, paymentReference];
}

class CancelSubscription extends SubscriptionEvent {
  final int subscriptionId;
  final String reason;

  const CancelSubscription(this.subscriptionId, this.reason);

  @override
  List<Object?> get props => [subscriptionId, reason];
}

class TestNotification extends SubscriptionEvent {
  final TestNotificationRequest request;

  const TestNotification(this.request);

  @override
  List<Object?> get props => [request];
}

class TestUserService extends SubscriptionEvent {
  final int userId;

  const TestUserService(this.userId);

  @override
  List<Object?> get props => [userId];
}

class HealthCheck extends SubscriptionEvent {}

// States
abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionPlansLoaded extends SubscriptionState {
  final List<SubscriptionPlanResource> plans;

  const SubscriptionPlansLoaded(this.plans);

  @override
  List<Object?> get props => [plans];
}

class SubscriptionLoaded extends SubscriptionState {
  final SubscriptionResource subscription;

  const SubscriptionLoaded(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

class SubscriptionCreated extends SubscriptionState {
  final SubscriptionResource subscription;

  const SubscriptionCreated(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

class SubscriptionRenewed extends SubscriptionState {
  final SubscriptionResource subscription;

  const SubscriptionRenewed(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

class SubscriptionCancelled extends SubscriptionState {
  final SubscriptionResource subscription;

  const SubscriptionCancelled(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

class TestResultLoaded extends SubscriptionState {
  final Map<String, dynamic> result;

  const TestResultLoaded(this.result);

  @override
  List<Object?> get props => [result];
}

class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionUseCases _useCases;

  SubscriptionBloc(this._useCases) : super(SubscriptionInitial()) {
    on<LoadSubscriptionPlans>(_onLoadSubscriptionPlans);
    on<LoadSubscriptionByUserId>(_onLoadSubscriptionByUserId);
    on<LoadSubscriptionById>(_onLoadSubscriptionById);
    on<CreateSubscription>(_onCreateSubscription);
    on<ActivateSubscription>(_onActivateSubscription);
    on<RenewSubscription>(_onRenewSubscription);
    on<CancelSubscription>(_onCancelSubscription);
    on<TestNotification>(_onTestNotification);
    on<TestUserService>(_onTestUserService);
    on<HealthCheck>(_onHealthCheck);
  }

  Future<void> _onLoadSubscriptionPlans(
    LoadSubscriptionPlans event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    try {
      final plans = await _useCases.getAllSubscriptionPlans();
      emit(SubscriptionPlansLoaded(plans));
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> _onLoadSubscriptionByUserId(
    LoadSubscriptionByUserId event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    try {
      final subscription = await _useCases.getSubscriptionByUserId(event.userId);
      if (subscription != null) {
        emit(SubscriptionLoaded(subscription));
      } else {
        emit(const SubscriptionError('No subscription found for this user'));
      }
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> _onLoadSubscriptionById(
    LoadSubscriptionById event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    try {
      final subscription = await _useCases.getSubscriptionById(event.subscriptionId);
      if (subscription != null) {
        emit(SubscriptionLoaded(subscription));
      } else {
        emit(const SubscriptionError('Subscription not found'));
      }
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> _onCreateSubscription(
    CreateSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    print('SubscriptionBloc: Starting subscription creation...');
    emit(SubscriptionLoading());
    try {
      print('SubscriptionBloc: Calling createSubscription use case...');
      final subscription = await _useCases.createSubscription(event.request);
      print('SubscriptionBloc: Subscription created successfully, emitting SubscriptionCreated state');
      emit(SubscriptionCreated(subscription));
    } catch (e) {
      print('SubscriptionBloc: Error creating subscription: $e');
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> _onActivateSubscription(
    ActivateSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    print('SubscriptionBloc: Starting subscription activation...');
    emit(SubscriptionLoading());
    try {
      print('SubscriptionBloc: Calling activateSubscription use case...');
      // Activar la suscripción
      final result = await _useCases.activateSubscription(
        event.subscriptionId,
        event.request,
      );
      
      print('Activation result: $result');
      print('SubscriptionBloc: Loading updated subscription...');
      
      // Después de activar, cargar la suscripción actualizada
      final updatedSubscription = await _useCases.getSubscriptionById(event.subscriptionId);
      
      if (updatedSubscription != null) {
        print('SubscriptionBloc: Subscription loaded successfully, emitting SubscriptionLoaded state');
        emit(SubscriptionLoaded(updatedSubscription));
      } else {
        print('SubscriptionBloc: Failed to load updated subscription');
        emit(const SubscriptionError('Failed to load updated subscription after activation'));
      }
    } catch (e) {
      print('SubscriptionBloc: Error activating subscription: $e');
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> _onRenewSubscription(
    RenewSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    try {
      final subscription = await _useCases.renewSubscription(
        event.subscriptionId,
        event.newSubscriptionType,
        event.paymentReference,
      );
      emit(SubscriptionRenewed(subscription));
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> _onCancelSubscription(
    CancelSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    try {
      final subscription = await _useCases.cancelSubscription(
        event.subscriptionId,
        event.reason,
      );
      emit(SubscriptionCancelled(subscription));
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> _onTestNotification(
    TestNotification event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    try {
      final result = await _useCases.testNotification(event.request);
      emit(TestResultLoaded(result));
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> _onTestUserService(
    TestUserService event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    try {
      final result = await _useCases.testUserService(event.userId);
      emit(TestResultLoaded(result));
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> _onHealthCheck(
    HealthCheck event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    try {
      final result = await _useCases.healthCheck();
      emit(TestResultLoaded(result));
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }
} 