import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculos_provider.dart';
import '../controllers/finance_controller.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String? _selectedTipo;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  final TextEditingController _busquedaController = TextEditingController();

  final Map<String, int> _tiposInteres = {
    'Todos': 0,
    'Simple': 1,
    'Compuesto': 2,
  };

  @override
  void initState() {
    super.initState();
    // Cargar historial al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CalculosProvider>(context, listen: false).cargarHistorial();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color colorMarca = const Color(0xFF00236B);
    final calculosProvider = Provider.of<CalculosProvider>(context);
    final finance = Provider.of<FinanceController>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      appBar: AppBar(
        title: const Text("Reportes", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: colorMarca,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // FILTROS
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              children: [
                // Rango de fechas
                Row(
                  children: [
                    Expanded(
                      child: _buildFechaField(
                        "Fecha Inicio",
                        _fechaInicio,
                            () => _selectFecha(true),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildFechaField(
                        "Fecha Fin",
                        _fechaFin,
                            () => _selectFecha(false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Buscador por tipo de interés
                DropdownButtonFormField<String>(
                  value: _selectedTipo,
                  hint: const Text("Buscar por tipo de interés..."),
                  items: const [
                    DropdownMenuItem(value: null, child: Text("Todos")),
                    DropdownMenuItem(value: "Simple", child: Text("Interés Simple")),
                    DropdownMenuItem(value: "Compuesto", child: Text("Interés Compuesto")),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedTipo = value);
                    calculosProvider.setFiltroTipo(value);
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),

                if (_fechaInicio != null || _fechaFin != null || _selectedTipo != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _fechaInicio = null;
                              _fechaFin = null;
                              _selectedTipo = null;
                            });
                            calculosProvider.limpiarFiltros();
                          },
                          icon: const Icon(Icons.clear),
                          label: const Text("Limpiar filtros"),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // LISTA DE REPORTES
          Expanded(
            child: calculosProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : calculosProvider.historial.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: calculosProvider.historial.length,
              itemBuilder: (context, index) {
                final calc = calculosProvider.historial[index];
                return _buildReportCard(calc);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFechaField(String label, DateTime? fecha, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[50],
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                fecha != null
                    ? DateFormat('dd/MM/yyyy').format(fecha)
                    : label,
                style: TextStyle(
                  color: fecha != null ? Colors.black : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectFecha(bool isInicio) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isInicio) {
          _fechaInicio = picked;
        } else {
          _fechaFin = picked;
        }
      });

      // Aplicar filtros
      Provider.of<CalculosProvider>(context, listen: false).setRangoFechas(
        _fechaInicio?.toIso8601String().split('T')[0],
        _fechaFin?.toIso8601String().split('T')[0],
      );
    }
  }

  Widget _buildReportCard(Map<String, dynamic> calc) {
    final fecha = DateTime.parse(calc['fecha_calculo'] ?? calc['fecha_calculo']);
    final tipo = calc['tipo_interes_nombre'] ?? calc['tipo_interes'];
    final capital = double.parse(calc['capital_inicial'].toString());
    final resultado = double.parse(calc['resultado_final'].toString());

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('yyyy-MM-dd').format(fecha),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: tipo == 'Simple' ? Colors.blue[50] : Colors.purple[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$tipo ${calc['periodo_tipo'] ?? ''}',
                  style: TextStyle(
                    color: tipo == 'Simple' ? Colors.blue[700] : Colors.purple[700],
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Capital inicial:',
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                'L. ${capital.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Resultado final:',
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                'L. ${resultado.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00C853),
                  fontSize: 16,
                ),
              ),
            ],
          ),
          if (calc['tasa_interes'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Tasa: ${calc['tasa_interes']}% | Tiempo: ${calc['tiempo_valor']} ${calc['periodo_tipo']?.toLowerCase() ?? 'años'}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
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
          Icon(Icons.bar_chart, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 10),
          const Text(
            "No hay cálculos registrados",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(
            "Realiza cálculos para verlos aquí",
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ],
      ),
    );
  }
}