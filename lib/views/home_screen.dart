import 'package:flutter/material.dart';
import 'dashboard_view.dart';
import 'reports_screen.dart';
import 'budget_view.dart';
import 'use_cases_view.dart';
import 'widgets/add_transaction_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardView(),   
    const UseCasesView(),    
    const BudgetView(),      
    const ReportsScreen(),   
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      // --- BOTÓN FLOTANTE CENTRAL (PLUS) ---
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_transaction_hero',
        onPressed: () => _showAddTransaction(context),
        backgroundColor: colorScheme.secondary, 
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // --- BARRA DE NAVEGACIÓN INFERIOR (CORREGIDA) ---
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0, // Reducido ligeramente para evitar tensiones de layout
        clipBehavior: Clip.antiAlias,
        // Usamos una altura fija para evitar el error de 1.00 pixel
        height: 70, 
        padding: EdgeInsets.zero,
        color: theme.bottomAppBarTheme.color ?? theme.cardColor,
        child: BottomNavigationBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: theme.disabledColor,
          selectedFontSize: 11, // Reducido un punto para ganar espacio vertical
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled), 
              label: "Inicio",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_graph), 
              label: "Simular",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet), 
              label: "Cartera",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), 
              label: "Reportes",
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTransaction(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTransactionModal(),
    );
  }
}