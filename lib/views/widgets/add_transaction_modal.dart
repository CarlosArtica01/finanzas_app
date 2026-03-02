import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/finance_controller.dart';

class AddTransactionModal extends StatefulWidget {
  const AddTransactionModal({super.key});

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  final _montoController = TextEditingController();
  final _tituloController = TextEditingController();
  
  TransactionType _tipoSeleccionado = TransactionType.gasto;
  AccountType _cuentaSeleccionada = AccountType.efectivo;
  final String _categoriaSeleccionada = 'General';

  @override
  void dispose() {
    _montoController.dispose();
    _tituloController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usamos read porque no necesitamos que el modal se reconstruya si cambian los datos globales
    final financeController = context.read<FinanceController>();
    final Color colorMarca = const Color(0xFF00236B);

    return Container(
      // 1. FONDO SÓLIDO Y BORDES REDONDEADOS
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: EdgeInsets.only(
        // Ajuste dinámico para que el teclado suba el modal
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 25, 
        right: 25, 
        top: 15
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Indicador visual de "arrastre"
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Nuevo Movimiento", 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorMarca), 
              textAlign: TextAlign.center
            ),
            const SizedBox(height: 25),
            
            // Selector de Tipo (Ingreso/Gasto) con estilo SYAC
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(
                  value: TransactionType.ingreso, 
                  label: Text("Ingreso"), 
                  icon: Icon(Icons.add_circle_outline)
                ),
                ButtonSegment(
                  value: TransactionType.gasto, 
                  label: Text("Gasto"), 
                  icon: Icon(Icons.remove_circle_outline)
                ),
              ],
              selected: {_tipoSeleccionado},
              onSelectionChanged: (val) => setState(() => _tipoSeleccionado = val.first),
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: _tipoSeleccionado == TransactionType.ingreso ? Colors.green[100] : Colors.red[100],
                selectedForegroundColor: _tipoSeleccionado == TransactionType.ingreso ? Colors.green[800] : Colors.red[800],
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _tituloController,
              decoration: InputDecoration(
                labelText: "Descripción",
                hintText: "Ej. Pago de Alquiler",
                prefixIcon: const Icon(Icons.description_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _montoController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              decoration: InputDecoration(
                labelText: "Monto",
                prefixText: "L. ",
                prefixIcon: const Icon(Icons.money),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 15),

            // Selector de Cuenta
            DropdownButtonFormField<AccountType>(
              value: _cuentaSeleccionada,
              decoration: InputDecoration(
                labelText: "Origen/Destino",
                prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: AccountType.values.map((type) => DropdownMenuItem(
                value: type, 
                child: Text(type.name.toUpperCase())
              )).toList(),
              onChanged: (val) => setState(() => _cuentaSeleccionada = val!),
            ),
            
            const SizedBox(height: 25),
            
            ElevatedButton(
              onPressed: () {
                double monto = double.tryParse(_montoController.text) ?? 0;
                double saldoDisponible = 0;

                // Obtener saldo actual de la cuenta seleccionada para mostrar el SnackBar
                if (_cuentaSeleccionada == AccountType.efectivo) saldoDisponible = financeController.saldoEfectivo;
                if (_cuentaSeleccionada == AccountType.banco) saldoDisponible = financeController.saldoBanco;
                if (_cuentaSeleccionada == AccountType.ahorros) saldoDisponible = financeController.saldoAhorros;

                if (_tipoSeleccionado == TransactionType.gasto && monto > saldoDisponible) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("⚠️ ¡Atención! El gasto supera el saldo disponible. La cuenta quedará en negativo."),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
                
                financeController.registrarMovimiento(
                  titulo: _tituloController.text,
                  monto: double.parse(_montoController.text),
                  cuenta: _cuentaSeleccionada,
                  tipo: _tipoSeleccionado,
                  categoria: _categoriaSeleccionada,
                );
                
                Navigator.pop(context); // Cerrar modal
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorMarca,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Confirmar Transacción", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}