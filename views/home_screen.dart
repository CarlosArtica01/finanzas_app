import 'package:flutter/material.dart';
import 'dashboard_view.dart';
import 'reports_screen.dart';
import 'use_cases_view.dart';
import 'simple_interes_view.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final Color colorMarca = const Color(0xFF00236B);

  final List<Widget> _pages = const [
    DashboardView(),
    SimpleInterestView(),
    ReportsScreen(),
    UseCasesView(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: colorMarca,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate_outlined), label: 'Calc'),
          BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: 'Reportes'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Gráficos'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Ajustes'),
        ],
      ),
    );
  }
}

