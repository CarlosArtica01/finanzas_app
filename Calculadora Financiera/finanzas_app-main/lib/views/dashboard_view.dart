import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/finance_controller.dart';
import '../providers/auth_provider.dart';
import '../providers/meta_provider.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  static const Color colorMarca = Color(0xFF00236B);
  static const Color colorPositivo = Color(0xFF00C853);
  static const Color colorFondo = Color(0xFFF8F8FA);

  @override
  Widget build(BuildContext context) {
    return Consumer2<FinanceController, AuthProvider>(
      builder: (context, finance, auth, child) {
        return Consumer<MetaProvider>(
          builder: (context, meta, child) {
            return Scaffold(
              backgroundColor: colorFondo,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                toolbarHeight: 80,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Sistema SYAC",
                      style: TextStyle(
                        color: colorMarca,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    Text(
                      "Bienvenid@, ${auth.userNombre.isNotEmpty ? auth.userNombre : 'Usuario'}",
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
                        child: const Icon(Icons.person, color: colorMarca),
                      ),
                      onPressed: () => Navigator.pushNamed(context, '/profile'),
                    ),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _cardResumen(
                          context,
                          "Saldo Total",
                          "L. ${finance.saldoTotalGeneral.toStringAsFixed(2)}",
                          Icons.account_balance,
                          Colors.orange,
                        ),
                        const SizedBox(width: 15),
                        _cardResumen(
                          context,
                          "Último Cálculo",
                          "L. ${finance.interestGenerated.toStringAsFixed(2)}",
                          Icons.trending_up,
                          colorPositivo,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Meta de Ahorro",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildMetaCard(meta.montoActual, meta.montoObjetivo),
                    const SizedBox(height: 30),
                    const Text(
                      "Acciones Rápidas",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _btnAccion(
                            context, "Nuevo cálculo\n de interés", Icons.calculate_outlined, Colors.blue, '/simple'),
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
      },
    );
  }

  Widget _cardResumen(
      BuildContext context, String label, String valor, IconData icono, Color color) {
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
                style: const TextStyle(color: colorMarca, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaCard(double actual, double meta) {
    final double progreso = (meta > 0) ? (actual / meta).clamp(0.0, 1.0) : 0.0;
    final int porcentaje = (progreso * 100).toInt();

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

  Widget _btnAccion(
      BuildContext context, String titulo, IconData icono, Color color, String route) {
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
