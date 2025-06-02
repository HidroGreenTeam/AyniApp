import '../../domain/usecases/walkthrough_use_case.dart';
import '../../../core/constants/walkthrough_config.dart';

/// ViewModel para el walkthrough siguiendo el patrón MVVM
/// Actúa como intermediario entre la Vista (BLoC) y el Modelo (Use Cases)
class WalkthroughViewModel {
  final WalkthroughUseCase _walkthroughUseCase;

  WalkthroughViewModel({
    required WalkthroughUseCase walkthroughUseCase,
  }) : _walkthroughUseCase = walkthroughUseCase;

  /// Obtiene los elementos del walkthrough
  List<WalkthroughItem> getWalkthroughItems() {
    return WalkthroughData.items;
  }

  /// Verifica si el walkthrough ya fue completado
  bool isWalkthroughCompleted() {
    return _walkthroughUseCase.isWalkthroughCompleted();
  }

  /// Marca el walkthrough como completado
  Future<void> completeWalkthrough() async {
    await _walkthroughUseCase.markWalkthroughCompleted();
  }

  /// Obtiene el total de páginas del walkthrough
  int getTotalPages() {
    return WalkthroughData.items.length;
  }

  /// Verifica si es la última página
  bool isLastPage(int currentIndex) {
    return currentIndex == getTotalPages() - 1;
  }

  /// Verifica si es la primera página
  bool isFirstPage(int currentIndex) {
    return currentIndex == 0;
  }
}
