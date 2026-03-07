import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/finance_controller.dart';

class BudgetView extends StatelessWidget {
  const BudgetView({super.key});

  @override
  Widget build(BuildContext context) {
    final Color colorMarca = const Color(0xFF00236B);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      appBar: AppBar(
        title: const Text("Mi Cartera", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: colorMarca,
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
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildAccountCard("Efectivo", finance.saldoEfectivo, Colors.green),
                    _buildAccountCard("Banco", finance.saldoBanco, Colors.blue),
                    _buildAccountCard("Ahorros", finance.saldoAhorros, Colors.orange),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "Movimientos Recientes",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              // --- LISTA DE MOVIMIENTOS ---
              Expanded(
                child: finance.movimientos.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: finance.movimientos.length,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemBuilder: (context, index) {
                          final mov = finance.movimientos[index];
                          final isGasto = mov['tipo'] == TransactionType.gasto;
                          final bool tieneAlerta = mov['alerta'] ?? false; // Detectamos el sobregiro

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              // Si tiene alerta de sobregiro, ponemos un borde sutil rojo
                              border: tieneAlerta 
                                ? Border.all(color: Colors.red.withOpacity(0.3)) 
                                : null,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: (isGasto ? Colors.red : Colors.green).withOpacity(0.1),
                                child: Icon(
                                  isGasto ? Icons.arrow_downward : Icons.arrow_upward,
                                  color: isGasto ? Colors.red : Colors.green,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Text(mov['titulo'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                  if (tieneAlerta) ...[
                                    const SizedBox(width: 8),
                                    const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 18),
                                  ]
                                ],
                              ),
                              subtitle: Text("${mov['categoria']} • ${mov['cuenta']}"),
                              trailing: Text(
                                "${isGasto ? '-' : '+'} L. ${mov['monto'].toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isGasto ? Colors.red : Colors.green,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // MÉTODO ACTUALIZADO: Cambia a rojo si el balance es negativo
  Widget _buildAccountCard(String name, double balance, Color colorBase) {
    final bool esNegativo = balance < 0;
    final Color colorUI = esNegativo ? Colors.red : colorBase;

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        // El borde se vuelve rojo sólido si hay deuda
        border: Border.all(
          color: esNegativo ? Colors.red : colorUI.withOpacity(0.3), 
          width: esNegativo ? 2 : 1
        ),
        boxShadow: [
          BoxShadow(
            color: colorUI.withOpacity(0.05), 
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
                color: esNegativo ? Colors.red : const Color(0xFF00236B)
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 10),
          const Text("No hay movimientos registrados", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}