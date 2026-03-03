import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/finance_controller.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color colorMarca = const Color(0xFF00236B);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      appBar: AppBar(
        title: const Text("Análisis de Gastos", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: colorMarca,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<FinanceController>(
        builder: (context, finance, child) {
          // Calculamos totales para el reporte
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- TARJETA DE RESUMEN GLOBAL ---
                _buildSummaryCard(totalIngresos, totalGastos),
                const SizedBox(height: 25),

                // --- GRÁFICA DE BARRAS NATIVA ---
                const Text("Comparativa Mensual", 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                _buildSimpleBarChart(totalIngresos, totalGastos),
                const SizedBox(height: 30),

                // --- SECCIÓN DE ALERTAS ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Alertas de Sobregiro", 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: alertasContador > 0 ? Colors.red[100] : Colors.green[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "$alertasContador detectadas",
                        style: TextStyle(
                          color: alertasContador > 0 ? Colors.red[800] : Colors.green[800],
                          fontSize: 12, fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Lista filtrada de movimientos con sobregiro
                if (alertasContador == 0)
                  _buildNoAlerts()
                else
                  ...finance.movimientos
                      .where((m) => m['alerta'] == true)
                      .map((m) => _buildAlertItem(m))
                      .toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(double ingresos, double gastos) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF00236B),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem("Ingresos", ingresos, Colors.greenAccent),
          Container(width: 1, height: 40, color: Colors.white24),
          _summaryItem("Gastos", gastos, Colors.orangeAccent),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 5),
        Text("L. ${amount.toStringAsFixed(2)}", 
          style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSimpleBarChart(double ingresos, double gastos) {
    double maxVal = ingresos > gastos ? ingresos : gastos;
    if (maxVal == 0) maxVal = 1; // Evitar división por cero

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _barRow("Ingresos", ingresos, maxVal, Colors.green),
          const SizedBox(height: 20),
          _barRow("Gastos", gastos, maxVal, Colors.red),
        ],
      ),
    );
  }

  Widget _barRow(String label, double val, double max, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 12,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
            ),
            FractionallySizedBox(
              widthFactor: (val / max).clamp(0.01, 1.0),
              child: Container(
                height: 12,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAlertItem(Map<String, dynamic> mov) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mov['titulo'], style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Excediste el saldo en ${mov['cuenta']}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          Text("-L. ${mov['monto'].toStringAsFixed(2)}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildNoAlerts() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline, size: 50, color: Colors.green[300]),
          const SizedBox(height: 10),
          const Text("¡Buen trabajo! No hay sobregiros.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}