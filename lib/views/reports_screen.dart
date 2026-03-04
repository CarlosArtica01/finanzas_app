import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/finance_controller.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Análisis de Gastos", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<FinanceController>(
        builder: (context, finance, child) {
          // Lógica de agregación de datos
          double totalIngresos = 0;
          double totalGastos = 0;
          int alertasContador = 0;

          for (var mov in finance.movimientos) {
            if (mov['tipo'] == TransactionType.ingreso) {
              totalIngresos += mov['monto'];
            } else {
              totalGastos += mov['monto'];
              if (mov['alerta'] == true) alertasContador++;
            }
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- TARJETA DE RESUMEN GLOBAL (MARCA) ---
                _buildSummaryCard(context, totalIngresos, totalGastos),
                
                const SizedBox(height: 30),

                // --- SECCIÓN DE GRÁFICOS ---
                Text("Comparativa de Flujo", 
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                _buildSimpleBarChart(context, totalIngresos, totalGastos),
                
                const SizedBox(height: 35),

                // --- SECCIÓN DE ALERTAS ---
                _buildAlertHeader(context, alertasContador),
                const SizedBox(height: 15),

                if (alertasContador == 0)
                  _buildNoAlerts(context)
                else
                  ...finance.movimientos
                      .where((m) => m['alerta'] == true)
                      .map((m) => _buildAlertItem(context, m)),
                
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, double ingresos, double gastos) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem("Ingresos", ingresos, Colors.greenAccent),
          Container(width: 1, height: 45, color: Colors.white24),
          _summaryItem("Gastos", gastos, Colors.orangeAccent),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Text("L. ${amount.toStringAsFixed(2)}", 
          style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
      ],
    );
  }

  Widget _buildSimpleBarChart(BuildContext context, double ingresos, double gastos) {
    final theme = Theme.of(context);
    double maxVal = ingresos > gastos ? ingresos : gastos;
    if (maxVal == 0) maxVal = 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          _barRow(context, "Ingresos Totales", ingresos, maxVal, Colors.green),
          const SizedBox(height: 25),
          _barRow(context, "Gastos Totales", gastos, maxVal, Colors.redAccent),
        ],
      ),
    );
  }

  Widget _barRow(BuildContext context, String label, double val, double max, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text("L. ${val.toStringAsFixed(0)}", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Container(
                  height: 10,
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10)
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  height: 10,
                  width: constraints.maxWidth * (val / max).clamp(0.02, 1.0),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2))]
                  ),
                ),
              ],
            );
          }
        ),
      ],
    );
  }

  Widget _buildAlertHeader(BuildContext context, int count) {
    final isError = count > 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Alertas de Presupuesto", 
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isError ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isError ? "$count Críticas" : "Al día",
            style: TextStyle(
              color: isError ? Colors.red : Colors.green,
              fontSize: 11, fontWeight: FontWeight.bold
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertItem(BuildContext context, Map<String, dynamic> mov) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: const Icon(Icons.priority_high_rounded, color: Colors.red, size: 20),
        ),
        title: Text(mov['titulo'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text("Cuenta: ${mov['cuenta']}", style: const TextStyle(fontSize: 12)),
        trailing: Text("-L. ${mov['monto'].toStringAsFixed(2)}", 
          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15)),
      ),
    );
  }

  Widget _buildNoAlerts(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.verified_user_rounded, size: 60, color: Colors.green.withValues(alpha: 0.3)),
          const SizedBox(height: 15),
          const Text("Tu salud financiera está en orden", 
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}