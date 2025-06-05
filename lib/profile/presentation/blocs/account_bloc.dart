import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../auth/data/models/auth_models.dart';
import '../viewmodels/account_viewmodel.dart';

// Events
abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object> get props => [];
}

class AccountLoadUser extends AccountEvent {
  const AccountLoadUser();
}

class AccountSignOutRequested extends AccountEvent {
  const AccountSignOutRequested();
}

// State
enum AccountStatus { initial, loading, loaded, signingOut, signedOut, failure }

class AccountState extends Equatable {
  final AccountStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AccountState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  factory AccountState.initial() {
    return const AccountState(
      status: AccountStatus.initial,
    );
  }

  AccountState copyWith({
    AccountStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AccountState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}

// Bloc
class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final AccountViewModel _accountViewModel;

  AccountBloc({required AccountViewModel accountViewModel})
      : _accountViewModel = accountViewModel,
        super(AccountState.initial()) {
    on<AccountLoadUser>(_onLoadUser);
    on<AccountSignOutRequested>(_onSignOutRequested);
  }

  void _onLoadUser(AccountLoadUser event, Emitter<AccountState> emit) {
    emit(state.copyWith(status: AccountStatus.loading));
    
    try {
      final user = _accountViewModel.getCurrentUser();
      emit(state.copyWith(
        status: AccountStatus.loaded,
        user: user,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AccountStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSignOutRequested(AccountSignOutRequested event, Emitter<AccountState> emit) async {
    emit(state.copyWith(status: AccountStatus.signingOut));
    
    try {
      await _accountViewModel.signOut();
      emit(state.copyWith(status: AccountStatus.signedOut));
    } catch (e) {
      emit(state.copyWith(
        status: AccountStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
