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
  String _periodo = 'Anual';
  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  @override
  void initState() {
    super.initState();
    _fechaInicio = DateTime.now();
    _fechaFin = DateTime.now().add(const Duration(days: 365));

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

  Future<void> _pickDate(bool isStart) async {
    final current = isStart ? _fechaInicio ?? DateTime.now() : _fechaFin ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;

    setState(() {
      if (isStart) {
        _fechaInicio = picked;
        if (_fechaFin != null && _fechaFin!.isBefore(picked)) {
          _fechaFin = picked;
        }
      } else {
        _fechaFin = picked;
      }
    });
  }

  Future<void> _ejecutarCalculo() async {
    final p = double.tryParse(_capitalController.text) ?? 0;
    final r = double.tryParse(_tasaController.text) ?? 0;
    final t = double.tryParse(_tiempoController.text) ?? 0;

    if (p <= 0 || r <= 0 || t <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa los campos numéricos con valores válidos')),
      );
      return;
    }

    final controller = context.read<FinanceController>();
    if (_esCompuesto) {
      controller.processCompoundInterest(p, r, t);
    } else {
      controller.processSimpleInterest(p, r, t);
    }

    final inicio = _fechaInicio ?? DateTime.now();
    final fin = _fechaFin ?? DateTime.now().add(const Duration(days: 365));

    await ApiService.guardarCalculo(
      idTipoInteres: _esCompuesto ? 2 : 1,
      capitalInicial: p,
      tasaInteres: r,
      periodoTipo: _periodo,
      tiempoValor: t.toInt(),
      fechaInicio: _fmtDate(inicio),
      fechaFin: _fmtDate(fin),
      resultadoFinal: controller.totalAmountCalculated,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cálculo guardado en tu historial'), backgroundColor: Color(0xFF1FA750)),
    );
    context.read<CalculosProvider>().cargarHistorial();
  }

  String _fmtDate(DateTime d) {
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 4),
              const Center(
                child: Text(
                  'Calculadora de Interés',
                  style: TextStyle(color: Color(0xFF254E81), fontWeight: FontWeight.w700, fontSize: 30),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9ECEF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _tab('Interés Simple', !_esCompuesto),
                    _tab('Interés Compuesto', _esCompuesto),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _field(_capitalController, '?? Capital inicial (L.)'),
              const SizedBox(height: 8),
              _field(_tasaController, '?? Tasa de interés anual (%)'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _field(_tiempoController, '? Tiempo')),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 54,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F3F5),
                        border: Border.all(color: const Color(0xFFD1D7DD)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _periodo,
                          items: const [
                            DropdownMenuItem(value: 'Anual', child: Text('Años')),
                            DropdownMenuItem(value: 'Mensual', child: Text('Meses')),
                            DropdownMenuItem(value: 'Trimestral', child: Text('Trimestres')),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _periodo = v);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _dateField('?? Fecha inicio', _fechaInicio, () => _pickDate(true))),
                  const SizedBox(width: 8),
                  Expanded(child: _dateField('?? Fecha fin', _fechaFin, () => _pickDate(false))),
                ],
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: _ejecutarCalculo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF254E81),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Calcular', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 14),
              if (finance.totalAmountCalculated > 0)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F5),
                    border: Border.all(color: const Color(0xFFD1D7DD)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Interés generado: L. ${finance.interestGenerated.toStringAsFixed(2)}'),
                      const SizedBox(height: 4),
                      Text(
                        'Monto total: L. ${finance.totalAmountCalculated.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1FA750)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab(String text, bool active) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _esCompuesto = text.contains('Compuesto')),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFF5F5F5) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: active ? const Color(0xFF254E81) : const Color(0xFF6F7780),
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF1F3F5),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD1D7DD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF254E81)),
        ),
      ),
    );
  }

  Widget _dateField(String label, DateTime? date, VoidCallback onTap) {
    final text = date == null
        ? label
        : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 54,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F5),
          border: Border.all(color: const Color(0xFFD1D7DD)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(text, style: const TextStyle(color: Color(0xFF4D545B))),
      ),
    );
  }
}

