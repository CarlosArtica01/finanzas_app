import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/finance_controller.dart';
import '../models/case_model.dart';
import 'simple_interes_view.dart';

class UseCasesView extends StatelessWidget {
  const UseCasesView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color colorMarca = Color(0xFF00236B);
    final controller = context.watch<FinanceController>(); 

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      appBar: AppBar(
        title: const Text("Escenarios de Inversión", 
          style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: colorMarca,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: controller.casosUso.length,
        itemBuilder: (context, index) {
          final caso = controller.casosUso[index];
          return _buildCaseCard(context, caso);
        },
      ),
    );
  }

  Widget _buildCaseCard(BuildContext context, FinancialCase caso) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), 
            blurRadius: 10,
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: caso.isCompound ? Colors.purple[50] : Colors.blue[50],
          child: Icon(
            caso.isCompound ? Icons.bolt : Icons.trending_up,
            color: caso.isCompound ? Colors.purple : Colors.blue,
          ),
        ),
        title: Text(
          caso.title, 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            caso.description,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: () => _aplicarCaso(context, caso),
      ),
    );
  }

  void _aplicarCaso(BuildContext context, FinancialCase caso) {
    // 1. Mostramos un feedback visual rápido
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Aplicando: ${caso.title}"),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF00236B),
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SimpleInterestView(initialCase: caso),
      ),
    );
  }
}