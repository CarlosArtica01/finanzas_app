import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculos_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CalculosProvider>().cargarHistorial();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;

    setState(() {
      if (isStart) {
        _fechaInicio = picked;
      } else {
        _fechaFin = picked;
      }
    });

    context.read<CalculosProvider>().setRangoFechas(_apiDate(_fechaInicio), _apiDate(_fechaFin));
  }

  String? _apiDate(DateTime? d) {
    if (d == null) return null;
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  void _applySearch(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) {
      context.read<CalculosProvider>().setFiltroTipo(null);
      return;
    }

    if (normalized.contains('simple')) {
      context.read<CalculosProvider>().setFiltroTipo('Simple');
      return;
    }

    if (normalized.contains('comp')) {
      context.read<CalculosProvider>().setFiltroTipo('Compuesto');
      return;
    }

    context.read<CalculosProvider>().setFiltroTipo('Todos');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalculosProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            const Text(
              'Reportes',
              style: TextStyle(color: Color(0xFF254E81), fontWeight: FontWeight.w700, fontSize: 30),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rango de fechas', style: TextStyle(color: Color(0xFF5B5B5B))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _dateBox(_fechaInicio, '01/01/2025', () => _pickDate(true))),
                      const SizedBox(width: 8),
                      Expanded(child: _dateBox(_fechaFin, '31/12/2025', () => _pickDate(false))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _searchController,
                    onChanged: _applySearch,
                    decoration: InputDecoration(
                      hintText: '?? Buscar por tipo de interés...',
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
                  ),
                ],
              ),
            ),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.historial.isEmpty
                      ? const Center(child: Text('No hay cálculos registrados'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          itemCount: provider.historial.length,
                          itemBuilder: (_, i) => _reportCard(provider.historial[i]),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateBox(DateTime? d, String fallback, VoidCallback onTap) {
    final label = d == null
        ? fallback
        : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD1D7DD)),
        ),
        child: Text('$label ??', style: const TextStyle(color: Color(0xFF666666))),
      ),
    );
  }

  Widget _reportCard(Map<String, dynamic> calc) {
    final fechaRaw = calc['fecha_calculo']?.toString() ?? '';
    final fecha = fechaRaw.length >= 10 ? fechaRaw.substring(0, 10) : fechaRaw;
    final tipo = (calc['tipo_interes_nombre'] ?? calc['tipo_interes'] ?? 'N/A').toString();
    final periodo = (calc['periodo_tipo'] ?? '').toString();
    final capital = double.tryParse((calc['capital_inicial'] ?? 0).toString()) ?? 0;
    final resultado = double.tryParse((calc['resultado_final'] ?? 0).toString()) ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        border: Border.all(color: const Color(0xFFD1D7DD)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fecha: $fecha', style: const TextStyle(fontWeight: FontWeight.w700)),
          Text('Tipo de interés: $tipo $periodo'),
          Text('Capital inicial: L. ${capital.toStringAsFixed(2)}'),
          Text(
            'Resultado final: L. ${resultado.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

