import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/finance_controller.dart';
import '../models/case_model.dart';
import 'simple_interes_view.dart';

class UseCasesView extends StatelessWidget {
  const UseCasesView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Usamos context.read para obtener los casos sin redibujar innecesariamente
    final controller = context.read<FinanceController>(); 

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Escenarios de Inversión", 
          style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        itemCount: controller.casosUso.length,
        itemBuilder: (context, index) {
          final caso = controller.casosUso[index];
          return _buildCaseCard(context, caso);
        },
      ),
    );
  }

  Widget _buildCaseCard(BuildContext context, FinancialCase caso) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), 
            blurRadius: 10,
            offset: const Offset(0, 5)
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ListTile(
          contentPadding: const EdgeInsets.all(20),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: caso.isCompound 
                ? Colors.purple.withOpacity(0.1) 
                : colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              caso.isCompound ? Icons.auto_graph_rounded : Icons.show_chart_rounded,
              color: caso.isCompound ? Colors.purple : colorScheme.primary,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  caso.title, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                ),
              ),
              _buildTypeBadge(caso.isCompound),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              caso.description,
              style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7), fontSize: 13, height: 1.4),
            ),
          ),
          onTap: () => _aplicarCaso(context, caso),
        ),
      ),
    );
  }

  Widget _buildTypeBadge(bool isCompound) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCompound ? Colors.purple.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isCompound ? "Compuesto" : "Simple",
        style: TextStyle(
          fontSize: 10, 
          fontWeight: FontWeight.bold, 
          color: isCompound ? Colors.purple : Colors.blue
        ),
      ),
    );
  }

  void _aplicarCaso(BuildContext context, FinancialCase caso) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Simulando escenario: ${caso.title}"),
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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