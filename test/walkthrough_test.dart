import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ayni/core/services/storage_service.dart';
import 'package:ayni/auth/domain/usecases/walkthrough_use_case.dart';

void main() {
  group('Walkthrough Tests', () {
    late StorageService storageService;
    late WalkthroughUseCase walkthroughUseCase;

    setUp(() async {
      // Initialize shared preferences for testing
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storageService = StorageService(prefs);
      walkthroughUseCase = WalkthroughUseCase(storageService);
    });

    test('should return false for first-time user', () {
      // Arrange - fresh installation
      
      // Act
      final isCompleted = walkthroughUseCase.isWalkthroughCompleted();
      
      // Assert
      expect(isCompleted, false);
    });

    test('should return true after marking walkthrough as completed', () async {
      // Arrange
      expect(walkthroughUseCase.isWalkthroughCompleted(), false);
      
      // Act
      await walkthroughUseCase.markWalkthroughCompleted();
      
      // Assert
      expect(walkthroughUseCase.isWalkthroughCompleted(), true);
    });

    test('should reset walkthrough state', () async {
      // Arrange
      await walkthroughUseCase.markWalkthroughCompleted();
      expect(walkthroughUseCase.isWalkthroughCompleted(), true);
      
      // Act
      await walkthroughUseCase.resetWalkthrough();
      
      // Assert
      expect(walkthroughUseCase.isWalkthroughCompleted(), false);
    });
  });
}
