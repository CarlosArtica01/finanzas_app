import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/finance_controller.dart';

class BudgetView extends StatelessWidget {
  const BudgetView({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos el tema actual para adaptabilidad automática
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // Usamos el color de fondo definido en el tema
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Mi Cartera", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: colorScheme.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<FinanceController>(
        builder: (context, finance, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // --- SECCIÓN DE CUENTAS ---
              _buildAccountsHeader(finance),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Movimientos Recientes",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // --- LISTA DE MOVIMIENTOS ---
              Expanded(
                child: finance.movimientos.isEmpty
                    ? _buildEmptyState(theme)
                    : ListView.builder(
                        itemCount: finance.movimientos.length,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemBuilder: (context, index) {
                          final mov = finance.movimientos[index];
                          return _MovimientoItem(mov: mov);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Abstracción de la lista horizontal de cuentas
  Widget _buildAccountsHeader(FinanceController finance) {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _AccountCard(name: "Efectivo", balance: finance.saldoEfectivo, colorBase: Colors.green),
          _AccountCard(name: "Banco", balance: finance.saldoBanco, colorBase: Colors.blue),
          _AccountCard(name: "Ahorros", balance: finance.saldoAhorros, colorBase: Colors.orange),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 80, color: theme.disabledColor),
          const SizedBox(height: 10),
          Text("No hay movimientos registrados", style: TextStyle(color: theme.disabledColor)),
        ],
      ),
    );
  }
}

// --- SUB-WIDGETS PARA MEJORAR EL MANTENIMIENTO ---

class _AccountCard extends StatelessWidget {
  final String name;
  final double balance;
  final Color colorBase;

  const _AccountCard({required this.name, required this.balance, required this.colorBase});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool esNegativo = balance < 0;
    // En modo oscuro, usamos colores un poco más brillantes para visibilidad
    final Color colorUI = esNegativo ? Colors.redAccent : colorBase;

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: esNegativo ? Colors.red : colorUI.withOpacity(0.3), 
          width: esNegativo ? 2 : 1
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.2 : 0.05), 
            blurRadius: 10
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: TextStyle(color: colorUI, fontWeight: FontWeight.bold, fontSize: 14)),
              if (esNegativo) const Icon(Icons.warning_rounded, color: Colors.red, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              "L. ${balance.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold, 
                color: esNegativo ? Colors.red : theme.colorScheme.onSurface
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MovimientoItem extends StatelessWidget {
  final Map<String, dynamic> mov;
  const _MovimientoItem({required this.mov});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isGasto = mov['tipo'] == TransactionType.gasto;
    final bool tieneAlerta = mov['alerta'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        border: tieneAlerta 
          ? Border.all(color: Colors.red.withValues(alpha: 0.3)) 
          : null,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (isGasto ? Colors.red : Colors.green).withValues(alpha: 0.1),
          child: Icon(
            isGasto ? Icons.arrow_downward : Icons.arrow_upward,
            color: isGasto ? Colors.redAccent : Colors.greenAccent,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                mov['titulo'], 
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (tieneAlerta) ...[
              const SizedBox(width: 8),
              const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 18),
            ]
          ],
        ),
        subtitle: Text(
          "${mov['categoria']} • ${mov['cuenta']}",
          style: theme.textTheme.bodySmall,
        ),
        trailing: Text(
          "${isGasto ? '-' : '+'} L. ${mov['monto'].toStringAsFixed(2)}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isGasto ? Colors.redAccent : Colors.greenAccent,
          ),
        ),
      ),
    );
  }
}