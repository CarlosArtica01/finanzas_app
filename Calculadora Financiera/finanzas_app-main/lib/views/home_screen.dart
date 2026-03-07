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

  final Color colorMarca = const Color(0xFF00236B);
  final Color colorAccion = const Color(0xFF00C853);

  // Lista de las vistas integradas
  final List<Widget> _pages = [
    const DashboardView(),   // 0: Inicio
    const UseCasesView(),    // 1: Casos de Uso
    const BudgetView(),      // 2: Cuentas
    const ReportsScreen(),   // 3: Gráficos y Reportes
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      // BOTÓN FLOTANTE CENTRAL (PLUS)
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransaction(context),
        backgroundColor: colorAccion,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      
      // Ubicación del botón en el centro de la barra inferior
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        clipBehavior: Clip.antiAlias,
        child: BottomNavigationBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: colorMarca,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Inicio"),
            BottomNavigationBarItem(icon: Icon(Icons.auto_graph), label: "Simular"),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: "Cartera"),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Reportes"),
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