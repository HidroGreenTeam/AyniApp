import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'core/services/theme_service.dart';
import 'core/services/localization_service.dart';
import 'auth/presentation/pages/splash_page.dart';
import 'treatment/presentation/pages/treatments_page.dart';
import 'treatment/presentation/pages/treatment_detail_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  
  // Initialize theme service
  final themeService = serviceLocator<ThemeService>();
  await themeService.initialize();
  
  // Initialize localization service
  final localizationService = serviceLocator<LocalizationService>();
  await localizationService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: serviceLocator<ThemeService>()),
        ChangeNotifierProvider.value(value: serviceLocator<LocalizationService>()),
      ],
      child: Consumer2<ThemeService, LocalizationService>(
        builder: (context, themeService, localizationService, child) {
          return MaterialApp(
            title: 'Ayni',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeService.themeMode,
            locale: localizationService.currentLocale,
            supportedLocales: LocalizationService.supportedLocales,
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const SplashPage(),
            routes: {
              '/treatments': (context) {
                final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
                return TreatmentsPage(arguments: args);
              },
              '/treatment-detail': (context) {
                final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
                final treatmentId = args?['treatmentId'] as int?;
                if (treatmentId == null) {
                  // Si no hay ID, regresar a la página anterior
                  Navigator.pop(context);
                  return const SizedBox.shrink();
                }
                return TreatmentDetailPage(treatmentId: treatmentId);
              },
            },
          );
        },
      ),
    );
  }
}
