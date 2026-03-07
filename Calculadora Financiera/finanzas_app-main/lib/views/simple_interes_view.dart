import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/finance_controller.dart';
import '../models/case_model.dart';
import '../providers/calculos_provider.dart';
import '../services/api_service.dart';

class SimpleInterestView extends StatefulWidget {
  final FinancialCase? initialCase;

  const SimpleInterestView({super.key, this.initialCase});

  @override
  State<SimpleInterestView> createState() => _SimpleInterestViewState();
}

class _SimpleInterestViewState extends State<SimpleInterestView> {
  final _capitalController = TextEditingController();
  final _tasaController = TextEditingController();
  final _tiempoController = TextEditingController();
  bool _esCompuesto = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialCase != null) {
      _capitalController.text = widget.initialCase!.principal.toString();
      _tasaController.text = widget.initialCase!.rate.toString();
      _tiempoController.text = widget.initialCase!.term.toString();
      _esCompuesto = widget.initialCase!.isCompound;
    }
  }

  @override
  void dispose() {
    _capitalController.dispose();
    _tasaController.dispose();
    _tiempoController.dispose();
    super.dispose();
  }

  Future<void> _ejecutarCalculo(BuildContext context) async {
    final p = double.tryParse(_capitalController.text) ?? 0;
    final r = double.tryParse(_tasaController.text) ?? 0;
    final t = double.tryParse(_tiempoController.text) ?? 0;

    final controller = context.read<FinanceController>();

    if (_esCompuesto) {
      controller.processCompoundInterest(p, r, t);
    } else {
      controller.processSimpleInterest(p, r, t);
    }

    final fechaInicio = DateTime.now();
    final fechaFin = fechaInicio.add(Duration(days: (t * 365).toInt()));
    final idTipo = _esCompuesto ? 2 : 1;

    await ApiService.guardarCalculo(
      idTipoInteres: idTipo,
      capitalInicial: p,
      tasaInteres: r,
      periodoTipo: 'Anual',
      tiempoValor: t.toInt(),
      fechaInicio: fechaInicio.toIso8601String().split('T')[0],
      fechaFin: fechaFin.toIso8601String().split('T')[0],
      resultadoFinal: controller.totalAmountCalculated,
    );

    if (context.mounted) {
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cálculo guardado en tu historial"),
          backgroundColor: Color(0xFF00C853),
        ),
      );
      Provider.of<CalculosProvider>(context, listen: false).cargarHistorial();
    }
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceController>();
    const Color colorMarca = Color(0xFF00236B);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Calculadora SYAC", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: colorMarca,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  _buildTabItem("Interés Simple", !_esCompuesto),
                  _buildTabItem("Interés Compuesto", _esCompuesto),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildTextField(_capitalController, "Capital Inicial (L.)", Icons.account_balance_wallet),
            const SizedBox(height: 15),
            _buildTextField(_tasaController, "Tasa de Interés Anual (%)", Icons.percent),
            const SizedBox(height: 15),
            _buildTextField(_tiempoController, "Tiempo (Años)", Icons.timer_outlined),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _ejecutarCalculo(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: colorMarca,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text(
                "Calcular Rendimiento",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 40),
            if (finance.totalAmountCalculated > 0) ...[
              const Text(
                "Resultado Estimado",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              _buildResultCard(finance),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String label, bool active) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _esCompuesto = label.contains("Compuesto")),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)] : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              color: active ? const Color(0xFF00236B) : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF00236B)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildResultCard(FinanceController finance) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00236B).withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _resultRow("Interés Generado", "L. ${finance.interestGenerated.toStringAsFixed(2)}", Colors.green[700]!),
          const Divider(height: 25),
          _resultRow("Monto Total", "L. ${finance.totalAmountCalculated.toStringAsFixed(2)}", const Color(0xFF00236B)),
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 15, color: Colors.black54)),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
