import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/subscription_model.dart';
import '../../data/repositories/billing_repository.dart';

// Events
abstract class BillingEvent extends Equatable {
  const BillingEvent();

  @override
  List<Object> get props => [];
}

class BillingLoad extends BillingEvent {
  const BillingLoad();
}

class BillingSubscribeToPlan extends BillingEvent {
  final String planId;
  final BillingCycle billingCycle;
  final String? paymentMethodId;

  const BillingSubscribeToPlan({
    required this.planId,
    required this.billingCycle,
    this.paymentMethodId,
  });

  @override
  List<Object> get props => [planId, billingCycle, paymentMethodId ?? ''];
}

class BillingCancelSubscription extends BillingEvent {
  const BillingCancelSubscription();
}

class BillingUpdateBillingCycle extends BillingEvent {
  final BillingCycle billingCycle;

  const BillingUpdateBillingCycle(this.billingCycle);

  @override
  List<Object> get props => [billingCycle];
}

class BillingUpdatePaymentMethod extends BillingEvent {
  final String paymentMethodId;

  const BillingUpdatePaymentMethod(this.paymentMethodId);

  @override
  List<Object> get props => [paymentMethodId];
}

// State
enum BillingStatus { initial, loading, loaded, failure, subscribing, cancelling, updating }

class BillingState extends Equatable {
  final BillingStatus status;
  final List<SubscriptionPlan> subscriptionPlans;
  final Subscription? currentSubscription;
  final List<BillingHistoryItem> billingHistory;
  final String? errorMessage;

  const BillingState({
    required this.status,
    required this.subscriptionPlans,
    this.currentSubscription,
    required this.billingHistory,
    this.errorMessage,
  });

  factory BillingState.initial() {
    return const BillingState(
      status: BillingStatus.initial,
      subscriptionPlans: [],
      billingHistory: [],
    );
  }

  BillingState copyWith({
    BillingStatus? status,
    List<SubscriptionPlan>? subscriptionPlans,
    Subscription? currentSubscription,
    List<BillingHistoryItem>? billingHistory,
    String? errorMessage,
  }) {
    return BillingState(
      status: status ?? this.status,
      subscriptionPlans: subscriptionPlans ?? this.subscriptionPlans,
      currentSubscription: currentSubscription ?? this.currentSubscription,
      billingHistory: billingHistory ?? this.billingHistory,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        subscriptionPlans,
        currentSubscription,
        billingHistory,
        errorMessage,
      ];
}

// Bloc
class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final BillingRepository _repository;

  BillingBloc({required BillingRepository repository})
      : _repository = repository,
        super(BillingState.initial()) {
    on<BillingLoad>(_onLoad);
    on<BillingSubscribeToPlan>(_onSubscribeToPlan);
    on<BillingCancelSubscription>(_onCancelSubscription);
    on<BillingUpdateBillingCycle>(_onUpdateBillingCycle);
    on<BillingUpdatePaymentMethod>(_onUpdatePaymentMethod);
  }

  Future<void> _onLoad(BillingLoad event, Emitter<BillingState> emit) async {
    emit(state.copyWith(status: BillingStatus.loading));
    
    try {
      final plans = await _repository.getSubscriptionPlans();
      final subscription = await _repository.getCurrentSubscription();
      final history = await _repository.getBillingHistory();
      
      emit(state.copyWith(
        status: BillingStatus.loaded,
        subscriptionPlans: plans,
        currentSubscription: subscription,
        billingHistory: history,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BillingStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSubscribeToPlan(BillingSubscribeToPlan event, Emitter<BillingState> emit) async {
    emit(state.copyWith(status: BillingStatus.subscribing));
    
    try {
      final subscription = await _repository.subscribeToPlan(
        event.planId,
        event.billingCycle,
        event.paymentMethodId,
      );
      
      // Reload all data after subscription
      final plans = await _repository.getSubscriptionPlans();
      final history = await _repository.getBillingHistory();
      
      emit(state.copyWith(
        status: BillingStatus.loaded,
        subscriptionPlans: plans,
        currentSubscription: subscription,
        billingHistory: history,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BillingStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCancelSubscription(BillingCancelSubscription event, Emitter<BillingState> emit) async {
    emit(state.copyWith(status: BillingStatus.cancelling));
    
    try {
      await _repository.cancelSubscription();
      
      // Reload subscription data
      final subscription = await _repository.getCurrentSubscription();
      
      emit(state.copyWith(
        status: BillingStatus.loaded,
        currentSubscription: subscription,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BillingStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateBillingCycle(BillingUpdateBillingCycle event, Emitter<BillingState> emit) async {
    emit(state.copyWith(status: BillingStatus.updating));
    
    try {
      await _repository.updateBillingCycle(event.billingCycle);
      
      // Reload subscription data
      final subscription = await _repository.getCurrentSubscription();
      
      emit(state.copyWith(
        status: BillingStatus.loaded,
        currentSubscription: subscription,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BillingStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdatePaymentMethod(BillingUpdatePaymentMethod event, Emitter<BillingState> emit) async {
    emit(state.copyWith(status: BillingStatus.updating));
    
    try {
      await _repository.updatePaymentMethod(event.paymentMethodId);
      
      // Reload subscription data
      final subscription = await _repository.getCurrentSubscription();
      
      emit(state.copyWith(
        status: BillingStatus.loaded,
        currentSubscription: subscription,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BillingStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
} 