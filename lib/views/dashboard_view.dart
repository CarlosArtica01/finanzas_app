import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/finance_controller.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<FinanceController>(
      builder: (context, finance, child) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
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
                    color: colorScheme.primary, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 24
                  ),
                ),
                Text(
                  "Bienvenid@, ${finance.userName}",
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
              ],
            ),
            actions: [
              _buildAvatar(context, finance, colorScheme.primary),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- TARJETAS DE RESUMEN ---
                Row(
                  children: [
                    _CardResumen(
                      label: "Saldo Total", 
                      valor: "L. ${finance.saldoTotalGeneral.toStringAsFixed(2)}",
                      icono: Icons.account_balance, 
                      color: Colors.orange
                    ),
                    const SizedBox(width: 15),
                    _CardResumen(
                      label: "Último Cálculo", 
                      valor: "L. ${finance.interestGenerated.toStringAsFixed(2)}",
                      icono: Icons.trending_up, 
                      color: const Color(0xFF00C853)
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // --- META DE AHORRO ---
                Text(
                  "Meta de Ahorro",
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _MetaCard(actual: finance.saldoAhorros, meta: 10000), 
                const SizedBox(height: 30),

                // --- ACCIONES RÁPIDAS ---
                Text(
                  "Acciones Rápidas",
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _BtnAccion(titulo: "Interés\nSimple", icono: Icons.calculate_outlined, color: Colors.blue, route: '/simple'),
                    _BtnAccion(titulo: "Escenarios", icono: Icons.lightbulb_outline, color: Colors.purple, route: '/cases'),
                    _BtnAccion(titulo: "Reportes", icono: Icons.bar_chart, color: Colors.orange, route: '/reports'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatar(BuildContext context, FinanceController finance, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: IconButton(
        icon: CircleAvatar(
          radius: 20,
          backgroundImage: finance.imageFile != null ? FileImage(finance.imageFile!) : null,
          backgroundColor: primaryColor.withValues(alpha: 0.1),
          child: finance.imageFile == null 
              ? Icon(Icons.person, color: primaryColor, size: 22) 
              : null,
        ),
        onPressed: () => Navigator.pushNamed(context, '/profile'),
      ),
    );
  }
}

// --- SUB-WIDGETS PRIVADOS ---

class _CardResumen extends StatelessWidget {
  final String label, valor;
  final IconData icono;
  final Color color;

  const _CardResumen({required this.label, required this.valor, required this.icono, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Icon(icono, color: color, size: 28),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            FittedBox(
              child: Text(
                valor,
                style: TextStyle(
                  color: theme.colorScheme.primary, 
                  fontWeight: FontWeight.bold, 
                  fontSize: 18
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaCard extends StatelessWidget {
  final double actual, meta;
  const _MetaCard({required this.actual, required this.meta});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double progreso = (actual / meta).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5)],
      ),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: progreso,
            backgroundColor: theme.dividerColor.withValues(alpha: 0.1),
            color: const Color(0xFF00C853),
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Progreso: ${(progreso * 100).toInt()}%", style: const TextStyle(color: Colors.grey)),
              Text(
                "L. ${actual.toStringAsFixed(0)} / L. ${meta.toStringAsFixed(0)}",
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BtnAccion extends StatelessWidget {
  final String titulo, route;
  final IconData icono;
  final Color color;

  const _BtnAccion({required this.titulo, required this.icono, required this.color, required this.route});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        InkWell(
          onTap: () => Navigator.pushNamed(context, route),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 70, width: 70,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icono, color: color, size: 30),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          titulo,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}