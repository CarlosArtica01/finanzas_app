import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/finance_controller.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Notificaciones", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<FinanceController>(
        builder: (context, finance, child) {
          return ListView(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            children: [
              _buildHeader(theme, "Alertas de Dinero"),
              
              _buildSwitchItem(
                context: context,
                title: "Control de Gastos",
                subtitle: "Avisar cuando un gasto supere el presupuesto.",
                value: finance.notifyGastoExcesivo,
                onChanged: (val) async {
                  await finance.toggleNotification('gasto', val);
                },
                icon: Icons.trending_down,
              ),
              
              _buildSwitchItem(
                context: context,
                title: "Recordatorios de Ahorro",
                subtitle: "Alertas para tus metas de inversión.",
                value: finance.notifyRecordatorioAhorro,
                onChanged: (val) async {
                  await finance.toggleNotification('ahorro', val);
                },
                icon: Icons.savings_outlined,
              ),

              const SizedBox(height: 30),
              _buildHeader(theme, "Cuenta y Seguridad"),
              
              _buildSwitchItem(
                context: context,
                title: "Alertas de Seguridad",
                subtitle: "Notificar cambios de clave o accesos nuevos.",
                value: finance.notifySeguridad,
                onChanged: (val) async {
                  await finance.toggleNotification('seguridad', val);
                },
                icon: Icons.shield_outlined,
              ),
              
              const SizedBox(height: 40),
              
              // --- BANNER DE INFORMACIÓN DEL SISTEMA ---
              _buildSystemInfoBanner(theme, colorScheme.primary),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required Future<void> Function(bool) onChanged,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: SwitchListTile(
        activeColor: theme.colorScheme.primary,
        secondary: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
        value: value,
        onChanged: (val) async {
          await onChanged(val);
        },
      ),
    );
  }

  Widget _buildSystemInfoBanner(ThemeData theme, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: primaryColor.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: primaryColor, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              "Las notificaciones push requieren permisos del sistema operativo para funcionar correctamente.",
              style: theme.textTheme.bodySmall?.copyWith(
                color: primaryColor.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}