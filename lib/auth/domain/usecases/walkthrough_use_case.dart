import '../../../core/services/storage_service.dart';

/// Use case para manejar el estado del walkthrough
class WalkthroughUseCase {
  static const String _walkthroughCompletedKey = 'walkthrough_completed';
  final StorageService _storageService;

  WalkthroughUseCase(this._storageService);  /// Verifica si el walkthrough ya fue completado
  bool isWalkthroughCompleted() {
    return _storageService.getBool(_walkthroughCompletedKey) ?? false;
  }

  /// Marca el walkthrough como completado
  Future<void> markWalkthroughCompleted() async {
    await _storageService.setBool(_walkthroughCompletedKey, true);
  }
  /// Resetea el estado del walkthrough (útil para testing)
  Future<void> resetWalkthrough() async {
    await _storageService.setBool(_walkthroughCompletedKey, false);
  }
}
