import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/finance_controller.dart';
import '../models/case_model.dart';
import 'simple_interes_view.dart';

class UseCasesView extends StatelessWidget {
  const UseCasesView({super.key});

  @override
  Widget build(BuildContext context) {
    const colorMarca = Color(0xFF254E81);
    final controller = context.watch<FinanceController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Gráficos y Escenarios', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: colorMarca,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: controller.casosUso.length,
        itemBuilder: (_, index) => _buildCaseCard(context, controller.casosUso[index]),
      ),
    );
  }

  Widget _buildCaseCard(BuildContext context, FinancialCase caso) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD1D7DD)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: caso.isCompound ? const Color(0xFFE6DCF8) : const Color(0xFFD8E9F8),
          child: Icon(caso.isCompound ? Icons.show_chart : Icons.trending_up, color: const Color(0xFF254E81)),
        ),
        title: Text(caso.title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(caso.description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Aplicando: ${caso.title}')),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SimpleInterestView(initialCase: caso)),
          );
        },
      ),
    );
  }
}

