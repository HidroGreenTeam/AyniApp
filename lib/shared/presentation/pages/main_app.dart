import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../detection/presentation/pages/diagnose_page.dart';
import '../../../plant/presentation/pages/my_plants_page.dart';
import '../../../profile/presentation/pages/account_page.dart';
import '../../../camera/presentation/pages/camera_page.dart';
import '../widgets/auth_guard.dart';
import 'home_page.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;
  
  // List of pages to display in the bottom navigation
  final List<Widget> _pages = [
    const HomePage(),
    const DiagnosePage(),
    const CameraPage(), // Updated to use the actual camera page
    const MyPlantsPage(),
    const AccountPage(),
  ];
  
  void _onItemTapped(int index) {
    // Simply switch to the selected page
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,          selectedItemColor: AppColors.primaryGreen,
          unselectedItemColor: AppColors.grey500,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          onTap: _onItemTapped,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Diagnose',
            ),
            BottomNavigationBarItem(
              icon: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,                  color: AppColors.primaryGreen,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),                child: const Icon(
                  Icons.camera_alt,
                  color: AppColors.white,
                  size: 28,
                ),
              ),
              label: '',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.eco_outlined),
              label: 'My Plants',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}
