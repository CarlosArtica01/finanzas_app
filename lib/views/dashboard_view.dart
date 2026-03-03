import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/finance_controller.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  final Color colorMarca = const Color(0xFF00236B);
  final Color colorPositivo = const Color(0xFF00C853);
  final Color colorFondo = const Color(0xFFF8F8FA);

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceController>(
      builder: (context, finance, child) {
        return Scaffold(
          backgroundColor: colorFondo,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 80,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sistema SYAC",
                  style: TextStyle(
                    color: colorMarca, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 24
                  ),
                ),
                Text(
                  "Bienvenid@, ${finance.userName}", // Ahora sí reconoce 'finance'
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: IconButton(
                  icon: CircleAvatar(
                    backgroundColor: colorMarca.withOpacity(0.1),
                    child: Icon(Icons.person, color: colorMarca),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tarjetas de Resumen Dinámicas
                Row(
                  children: [
                    _cardResumen(
                      "Saldo Total", 
                      "L. ${finance.saldoTotalGeneral.toStringAsFixed(2)}",
                      Icons.account_balance, 
                      Colors.orange
                    ),
                    const SizedBox(width: 15),
                    _cardResumen(
                      "Último Cálculo", 
                      "L. ${finance.interestGenerated.toStringAsFixed(2)}",
                      Icons.trending_up, 
                      colorPositivo
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Meta Dinámica
                const Text(
                  "Meta de Ahorro",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildMetaCard(finance.saldoAhorros, 10000), 
                const SizedBox(height: 30),

                // Acciones Rápidas
                const Text(
                  "Acciones Rápidas",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _btnAccion(context, "Interés\nSimple", Icons.calculate_outlined, Colors.blue, '/simple'),
                    _btnAccion(context, "Escenarios", Icons.lightbulb_outline, Colors.purple, '/cases'),
                    _btnAccion(context, "Reportes", Icons.bar_chart, Colors.orange, '/reports'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Widgets Auxiliares ---

  Widget _cardResumen(String label, String valor, IconData icono, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Icon(icono, color: color, size: 28),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            FittedBox(
              child: Text(
                valor,
                style: TextStyle(color: colorMarca, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaCard(double actual, double meta) {
    double progreso = (actual / meta).clamp(0.0, 1.0);
    int porcentaje = (progreso * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
      ),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: progreso,
            backgroundColor: Colors.grey[200],
            color: colorPositivo,
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Progreso: $porcentaje%", style: const TextStyle(color: Colors.grey)),
              Text(
                "L. ${actual.toStringAsFixed(0)} / L. ${meta.toStringAsFixed(0)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _btnAccion(BuildContext context, String titulo, IconData icono, Color color, String route) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, route),
          child: Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icono, color: color, size: 30),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          titulo,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ],
    );
  }
}