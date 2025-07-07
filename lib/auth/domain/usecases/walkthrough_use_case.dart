import '../../../core/services/storage_service.dart';

/// Use case para manejar el estado del walkthrough
class WalkthroughUseCase {
  static const String _walkthroughCompletedKey = 'walkthrough_completed';
  final StorageService _storageService;

  WalkthroughUseCase(this._storageService);  /// Verifica si el walkthrough ya fue completado
  bool isWalkthroughCompleted() {
    try {
      return _storageService.getBool(_walkthroughCompletedKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Marca el walkthrough como completado
  Future<void> markWalkthroughCompleted() async {
    try {
      await _storageService.setBool(_walkthroughCompletedKey, true);
    } catch (e) {
      // If marking fails, we can continue with the app flow
      // The user will see the walkthrough again next time
    }
  }
  /// Resetea el estado del walkthrough (útil para testing)
  Future<void> resetWalkthrough() async {
    await _storageService.setBool(_walkthroughCompletedKey, false);
  }
}
