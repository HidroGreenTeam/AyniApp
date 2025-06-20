import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/payment_method_model.dart';
import '../../data/repositories/payment_method_repository.dart';

// Events
abstract class PaymentMethodsEvent extends Equatable {
  const PaymentMethodsEvent();

  @override
  List<Object> get props => [];
}

class PaymentMethodsLoad extends PaymentMethodsEvent {
  const PaymentMethodsLoad();
}

class PaymentMethodAdd extends PaymentMethodsEvent {
  final PaymentMethodModel paymentMethod;

  const PaymentMethodAdd(this.paymentMethod);

  @override
  List<Object> get props => [paymentMethod];
}

class PaymentMethodUpdate extends PaymentMethodsEvent {
  final PaymentMethodModel paymentMethod;

  const PaymentMethodUpdate(this.paymentMethod);

  @override
  List<Object> get props => [paymentMethod];
}

class PaymentMethodDelete extends PaymentMethodsEvent {
  final String id;

  const PaymentMethodDelete(this.id);

  @override
  List<Object> get props => [id];
}

class PaymentMethodSetDefault extends PaymentMethodsEvent {
  final String id;

  const PaymentMethodSetDefault(this.id);

  @override
  List<Object> get props => [id];
}

// State
enum PaymentMethodsStatus { initial, loading, loaded, failure }

class PaymentMethodsState extends Equatable {
  final PaymentMethodsStatus status;
  final List<PaymentMethodModel> paymentMethods;
  final String? errorMessage;

  const PaymentMethodsState({
    required this.status,
    required this.paymentMethods,
    this.errorMessage,
  });

  factory PaymentMethodsState.initial() {
    return const PaymentMethodsState(
      status: PaymentMethodsStatus.initial,
      paymentMethods: [],
    );
  }

  PaymentMethodsState copyWith({
    PaymentMethodsStatus? status,
    List<PaymentMethodModel>? paymentMethods,
    String? errorMessage,
  }) {
    return PaymentMethodsState(
      status: status ?? this.status,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, paymentMethods, errorMessage];
}

// Bloc
class PaymentMethodsBloc extends Bloc<PaymentMethodsEvent, PaymentMethodsState> {
  final PaymentMethodRepository _repository;

  PaymentMethodsBloc({required PaymentMethodRepository repository})
      : _repository = repository,
        super(PaymentMethodsState.initial()) {
    on<PaymentMethodsLoad>(_onLoad);
    on<PaymentMethodAdd>(_onAdd);
    on<PaymentMethodUpdate>(_onUpdate);
    on<PaymentMethodDelete>(_onDelete);
    on<PaymentMethodSetDefault>(_onSetDefault);
  }

  Future<void> _onLoad(PaymentMethodsLoad event, Emitter<PaymentMethodsState> emit) async {
    emit(state.copyWith(status: PaymentMethodsStatus.loading));
    
    try {
      final paymentMethods = await _repository.getPaymentMethods();
      emit(state.copyWith(
        status: PaymentMethodsStatus.loaded,
        paymentMethods: paymentMethods,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PaymentMethodsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAdd(PaymentMethodAdd event, Emitter<PaymentMethodsState> emit) async {
    try {
      final newPaymentMethod = await _repository.addPaymentMethod(event.paymentMethod);
      final updatedMethods = List<PaymentMethodModel>.from(state.paymentMethods)
        ..add(newPaymentMethod);
      
      emit(state.copyWith(
        status: PaymentMethodsStatus.loaded,
        paymentMethods: updatedMethods,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PaymentMethodsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdate(PaymentMethodUpdate event, Emitter<PaymentMethodsState> emit) async {
    try {
      final updatedPaymentMethod = await _repository.updatePaymentMethod(event.paymentMethod);
      final updatedMethods = state.paymentMethods.map((method) {
        return method.id == updatedPaymentMethod.id ? updatedPaymentMethod : method;
      }).toList();
      
      emit(state.copyWith(
        status: PaymentMethodsStatus.loaded,
        paymentMethods: updatedMethods,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PaymentMethodsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDelete(PaymentMethodDelete event, Emitter<PaymentMethodsState> emit) async {
    try {
      await _repository.deletePaymentMethod(event.id);
      final updatedMethods = state.paymentMethods
          .where((method) => method.id != event.id)
          .toList();
      
      emit(state.copyWith(
        status: PaymentMethodsStatus.loaded,
        paymentMethods: updatedMethods,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PaymentMethodsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSetDefault(PaymentMethodSetDefault event, Emitter<PaymentMethodsState> emit) async {
    try {
      await _repository.setDefaultPaymentMethod(event.id);
      final updatedMethods = state.paymentMethods.map((method) {
        return method.copyWith(isDefault: method.id == event.id);
      }).toList();
      
      emit(state.copyWith(
        status: PaymentMethodsStatus.loaded,
        paymentMethods: updatedMethods,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PaymentMethodsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
} 