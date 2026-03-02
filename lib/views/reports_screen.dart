import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  final Color colorMarca = const Color(0xFF00236B);
  final Color colorPositivo = const Color(0xFF00C853);
  final Color colorFondo = const Color(0xFFF8F8FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Reportes Financieros", 
          style: TextStyle(color: colorMarca, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.download_rounded, color: colorMarca),
            onPressed: () {
              // Aquí iría la lógica para exportar a PDF
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Card de Resumen de Rendimiento
            _buildPerformanceCard(),
            const SizedBox(height: 25),

            // 2. Sección de Distribución (Gráfico visual)
            const Text("Distribución de Intereses", 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildDistributionChart(),
            const SizedBox(height: 25),

            // 3. Listado de cálculos recientes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Historial Reciente", 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: const Text("Ver todo")),
              ],
            ),
            const SizedBox(height: 10),
            _buildHistoryItem("Interés Simple", "L. 1,200.00", "15 Feb 2026", Icons.account_balance_wallet),
            _buildHistoryItem("Interés Compuesto", "L. 4,500.00", "10 Feb 2026", Icons.shutter_speed),
            _buildHistoryItem("Plan Jubilación", "L. 10,000.00", "01 Feb 2026", Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [colorMarca, const Color(0xFF0D47A1)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: colorMarca.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          const Text("Ganancia Total Acumulada", style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 10),
          const Text("L. 15,700.50", 
            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat("Crecimiento", "+12.5%"),
              Container(width: 1, height: 30, color: Colors.white24),
              _buildMiniStat("Proyección", "L. 20k"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDistributionChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          // Representación visual simple de un gráfico
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 80, width: 80,
                child: CircularProgressIndicator(
                  value: 0.7,
                  strokeWidth: 10,
                  backgroundColor: Colors.grey[200],
                  color: colorPositivo,
                ),
              ),
              const Text("70%", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(width: 25),
          Expanded(
            child: Column(
              children: [
                _buildLegendItem("Fijo", colorPositivo),
                _buildLegendItem("Variable", colorMarca),
                _buildLegendItem("Otros", Colors.orange),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildHistoryItem(String title, String amount, String date, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: colorFondo, child: Icon(icon, color: colorMarca)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(amount, style: TextStyle(color: colorPositivo, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}