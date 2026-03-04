import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/finance_controller.dart';
import '../models/case_model.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final finance = context.watch<FinanceController>();
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Calculadora SYAC", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- SELECTOR DE TIPO (TAB) ---
            _buildTypeSelector(theme),
            
            const SizedBox(height: 30),

            // --- FÓRMULA EDUCATIVA ---
            _buildFormulaHeader(theme),
            const SizedBox(height: 25),

            // --- CAMPOS DE ENTRADA ---
            _buildTextField(context, _capitalController, "Capital Inicial (L.)", Icons.account_balance_wallet_outlined),
            const SizedBox(height: 15),
            _buildTextField(context, _tasaController, "Tasa de Interés Anual (%)", Icons.percent_rounded),
            const SizedBox(height: 15),
            _buildTextField(context, _tiempoController, "Tiempo (Años)", Icons.hourglass_empty_rounded),
            
            const SizedBox(height: 30),

            // --- BOTÓN CALCULAR ---
            ElevatedButton(
              onPressed: () => _ejecutarCalculo(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("Calcular Rendimiento", 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 35),

            // --- RESULTADOS ---
            if (finance.totalAmountCalculated > 0) ...[
              Text("Proyección Final", 
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _buildResultCard(context, finance),
              const SizedBox(height: 20),
              _buildEducationalNote(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: theme.dividerColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          _buildTabItem("Interés Simple", !_esCompuesto, theme),
          _buildTabItem("Interés Compuesto", _esCompuesto, theme),
        ],
      ),
    );
  }

  Widget _buildFormulaHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.functions_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              _esCompuesto 
                ? "Fórmula: \$\$A = P(1 + r)^t\$\$" 
                : "Fórmula: \$\$I = P \\times r \\times t\$\$",
              style: TextStyle(fontFamily: 'monospace', color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _ejecutarCalculo(BuildContext context) {
    double p = double.tryParse(_capitalController.text) ?? 0;
    double r = double.tryParse(_tasaController.text) ?? 0;
    double t = double.tryParse(_tiempoController.text) ?? 0;

    final controller = context.read<FinanceController>();
    if (_esCompuesto) {
      controller.processCompoundInterest(p, r, t);
    } else {
      controller.processSimpleInterest(p, r, t);
    }
    FocusScope.of(context).unfocus();
  }

  Widget _buildTabItem(String label, bool active, ThemeData theme) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _esCompuesto = label.contains("Compuesto")),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? theme.cardColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)] : [],
          ),
          child: Text(label, 
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              color: active ? theme.colorScheme.primary : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, TextEditingController controller, String label, IconData icon) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        filled: true,
        fillColor: theme.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, FinanceController finance) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary.withOpacity(0.08), theme.colorScheme.primary.withOpacity(0.02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _resultRow("Interés Ganado", "L. ${finance.interestGenerated.toStringAsFixed(2)}", Colors.green),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Divider(),
          ),
          _resultRow("Monto Final", "L. ${finance.totalAmountCalculated.toStringAsFixed(2)}", theme.colorScheme.primary, isBold: true),
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(
          fontSize: isBold ? 22 : 18, 
          fontWeight: FontWeight.bold, 
          color: color,
          letterSpacing: -0.5
        )),
      ],
    );
  }

  Widget _buildEducationalNote(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.orange[400], size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              "El interés compuesto crece exponencialmente porque genera intereses sobre los intereses ya ganados.",
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}