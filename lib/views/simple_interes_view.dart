import 'package:flutter/material.dart';
import '../controllers/finance_controller.dart';
import '../models/case_model.dart';

class SimpleInterestView extends StatefulWidget {
  final FinancialCase? initialCase;

  const SimpleInterestView({super.key, this.initialCase});

  @override
  State<SimpleInterestView> createState() => _SimpleInterestViewState();
}

class _SimpleInterestViewState extends State<SimpleInterestView> {
  // 1. Controladores y variables de estado
  late TextEditingController pController;
  late TextEditingController rController;
  late TextEditingController tController;
  
  final FinanceController _financeController = FinanceController();
  final Color _colorMarca = const Color(0xFF00236B);
  final Color _colorExito = const Color(0xFF00C853);

  @override
  void initState() {
    super.initState();
    // Inicialización de controladores con datos de casos si existen
    pController = TextEditingController(
        text: widget.initialCase?.principal.toString() ?? "");
    rController = TextEditingController(
        text: widget.initialCase?.rate.toString() ?? "");
    tController = TextEditingController(
        text: widget.initialCase?.term.toString() ?? "");

    // Cálculo automático si viene de un caso de uso
    if (widget.initialCase != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _calcular());
    }
  }

  @override
  void dispose() {
    // Limpieza de controladores para liberar memoria
    pController.dispose();
    rController.dispose();
    tController.dispose();
    super.dispose();
  }

  void _calcular() {
    if (pController.text.isEmpty || rController.text.isEmpty || tController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, completa todos los campos")),
      );
      return;
    }

    // Usamos try-parse para evitar errores si el usuario ingresa caracteres no válidos
    final p = double.tryParse(pController.text) ?? 0.0;
    final r = double.tryParse(rController.text) ?? 0.0;
    final t = double.tryParse(tController.text) ?? 0.0;

    _financeController.processSimpleInterest(p, r, t);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      appBar: AppBar(
        title: const Text("Interés Simple", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: _colorMarca,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 25),
            _buildForm(),
            const SizedBox(height: 30),
            _buildCalculateButton(),
            const SizedBox(height: 30),
            _buildResultCard(),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS INTERNOS (COMPONENTIZACIÓN) ---

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.initialCase != null ? "Simulación: ${widget.initialCase!.title}" : "Nueva Simulación",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _colorMarca),
        ),
        const Text(
          "Calcula cuánto crecerá tu capital con un interés fijo.",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        _buildInput(pController, "Capital Inicial (L.)", Icons.account_balance_wallet),
        const SizedBox(height: 15),
        _buildInput(rController, "Tasa de Interés Anual (%)", Icons.percent),
        const SizedBox(height: 15),
        _buildInput(tController, "Tiempo (Años)", Icons.calendar_today),
      ],
    );
  }

  Widget _buildCalculateButton() {
    return ElevatedButton(
      onPressed: _calcular,
      style: ElevatedButton.styleFrom(
        backgroundColor: _colorMarca,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: const Text("Calcular Rendimiento", 
        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildResultCard() {
    return ListenableBuilder(
      listenable: _financeController,
      builder: (context, _) {
        return AnimatedOpacity(
          opacity: _financeController.totalAmountCalculated > 0 ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              children: [
                _buildResultRow("Interés Ganado:", "L. ${_financeController.interestGenerated.toStringAsFixed(2)}", Colors.blueGrey),
                const Divider(height: 30),
                _buildResultRow("Monto Total:", "L. ${_financeController.totalAmountCalculated.toStringAsFixed(2)}", _colorExito),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInput(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _colorMarca),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _colorMarca)),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}