import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/constants/walkthrough_config.dart';
import '../viewmodels/walkthrough_viewmodel.dart';

// Events
abstract class WalkthroughEvent extends Equatable {
  const WalkthroughEvent();

  @override
  List<Object> get props => [];
}

class WalkthroughStarted extends WalkthroughEvent {
  const WalkthroughStarted();
}

class WalkthroughPageChanged extends WalkthroughEvent {
  final int pageIndex;

  const WalkthroughPageChanged(this.pageIndex);

  @override
  List<Object> get props => [pageIndex];
}

class WalkthroughNextPressed extends WalkthroughEvent {
  const WalkthroughNextPressed();
}

class WalkthroughPreviousPressed extends WalkthroughEvent {
  const WalkthroughPreviousPressed();
}

class WalkthroughSkipPressed extends WalkthroughEvent {
  const WalkthroughSkipPressed();
}

class WalkthroughCompleted extends WalkthroughEvent {
  const WalkthroughCompleted();
}

// States
enum WalkthroughStatus { initial, loading, inProgress, completed }

class WalkthroughState extends Equatable {
  final WalkthroughStatus status;
  final int currentPageIndex;
  final List<WalkthroughItem> items;
  final bool isLastPage;
  final bool isFirstPage;

  const WalkthroughState({
    required this.status,
    required this.currentPageIndex,
    required this.items,
    required this.isLastPage,
    required this.isFirstPage,
  });

  factory WalkthroughState.initial() {
    return const WalkthroughState(
      status: WalkthroughStatus.initial,
      currentPageIndex: 0,
      items: [],
      isLastPage: false,
      isFirstPage: true,
    );
  }

  WalkthroughState copyWith({
    WalkthroughStatus? status,
    int? currentPageIndex,
    List<WalkthroughItem>? items,
    bool? isLastPage,
    bool? isFirstPage,
  }) {
    return WalkthroughState(
      status: status ?? this.status,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      items: items ?? this.items,
      isLastPage: isLastPage ?? this.isLastPage,
      isFirstPage: isFirstPage ?? this.isFirstPage,
    );
  }

  @override
  List<Object> get props => [
        status,
        currentPageIndex,
        items,
        isLastPage,
        isFirstPage,
      ];
}

// BLoC
class WalkthroughBloc extends Bloc<WalkthroughEvent, WalkthroughState> {
  final WalkthroughViewModel _walkthroughViewModel;

  WalkthroughBloc({
    required WalkthroughViewModel walkthroughViewModel,
  })  : _walkthroughViewModel = walkthroughViewModel,
        super(WalkthroughState.initial()) {
    on<WalkthroughStarted>(_onWalkthroughStarted);
    on<WalkthroughPageChanged>(_onPageChanged);
    on<WalkthroughNextPressed>(_onNextPressed);
    on<WalkthroughPreviousPressed>(_onPreviousPressed);
    on<WalkthroughSkipPressed>(_onSkipPressed);
    on<WalkthroughCompleted>(_onWalkthroughCompleted);
  }

  void _onWalkthroughStarted(
    WalkthroughStarted event,
    Emitter<WalkthroughState> emit,
  ) {
    final items = _walkthroughViewModel.getWalkthroughItems();
    emit(state.copyWith(
      status: WalkthroughStatus.inProgress,
      items: items,
      isFirstPage: true,
      isLastPage: items.length == 1,
    ));
  }

  void _onPageChanged(
    WalkthroughPageChanged event,
    Emitter<WalkthroughState> emit,
  ) {
    emit(state.copyWith(
      currentPageIndex: event.pageIndex,
      isFirstPage: _walkthroughViewModel.isFirstPage(event.pageIndex),
      isLastPage: _walkthroughViewModel.isLastPage(event.pageIndex),
    ));
  }

  void _onNextPressed(
    WalkthroughNextPressed event,
    Emitter<WalkthroughState> emit,
  ) {
    if (state.isLastPage) {
      add(const WalkthroughCompleted());
    } else {
      final nextIndex = state.currentPageIndex + 1;
      add(WalkthroughPageChanged(nextIndex));
    }
  }

  void _onPreviousPressed(
    WalkthroughPreviousPressed event,
    Emitter<WalkthroughState> emit,
  ) {
    if (!state.isFirstPage) {
      final previousIndex = state.currentPageIndex - 1;
      add(WalkthroughPageChanged(previousIndex));
    }
  }

  void _onSkipPressed(
    WalkthroughSkipPressed event,
    Emitter<WalkthroughState> emit,
  ) {
    add(const WalkthroughCompleted());
  }

  Future<void> _onWalkthroughCompleted(
    WalkthroughCompleted event,
    Emitter<WalkthroughState> emit,
  ) async {
    emit(state.copyWith(status: WalkthroughStatus.loading));
    
    try {
      await _walkthroughViewModel.completeWalkthrough();
      emit(state.copyWith(status: WalkthroughStatus.completed));
    } catch (e) {
      // En caso de error, continuar al flujo normal
      emit(state.copyWith(status: WalkthroughStatus.completed));
    }
  }
}
