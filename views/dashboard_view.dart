import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/finance_controller.dart';
import '../providers/auth_provider.dart';
import '../providers/meta_provider.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  static const Color _brand = Color(0xFF254E81);
  static const Color _bg = Color(0xFFF5F5F5);
  static const Color _card = Color(0xFFF1F3F5);

  @override
  Widget build(BuildContext context) {
    return Consumer3<FinanceController, AuthProvider, MetaProvider>(
      builder: (context, finance, auth, meta, _) {
        final nombre = auth.userNombre.isNotEmpty ? auth.userNombre : 'usuario';

        return Scaffold(
          backgroundColor: _bg,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Sistema SYAC',
                      style: TextStyle(color: _brand, fontWeight: FontWeight.w800, fontSize: 36),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Bienvenid@, $nombre',
                      style: const TextStyle(color: Color(0xFF666666), fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _topCard(
                          'Saldo Actual',
                          'L. ${finance.saldoTotalGeneral.toStringAsFixed(2)}',
                          '??',
                          const Color(0xFF254E81),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _topCard(
                          'Interés Mes',
                          'L. ${finance.interestGenerated.toStringAsFixed(1)}',
                          '??',
                          const Color(0xFF1FA750),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _card,
                      border: Border.all(color: const Color(0xFFD1D7DD)),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Meta Jubilación', style: TextStyle(fontSize: 16, color: Color(0xFF5B5B5B))),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            minHeight: 18,
                            value: meta.progreso,
                            backgroundColor: const Color(0xFFD8DDE2),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF9BDEA4)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            '${(meta.progreso * 100).toStringAsFixed(0)}% - L. ${meta.montoActual.toStringAsFixed(0)} / L. ${meta.montoObjetivo.toStringAsFixed(0)}',
                            style: const TextStyle(color: Color(0xFF6A6A6A), fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Acciones Rápidas', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _actionCard('?? Nueva\nCalculación', const Color(0xFF7FB9EE), const Color(0xFF4DA2EA)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _actionCard('?? Ver\nReportes', const Color(0xFFA4E3B1), const Color(0xFF73C98A)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _actionCard('?? Plan\nJubilación', const Color(0xFFF8E2BC), const Color(0xFFF2AE53)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('Cálculos Recientes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _card,
                      border: Border.all(color: const Color(0xFFD1D7DD)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Interés Compuesto - L. ${finance.interestGenerated.toStringAsFixed(3)} ? L. ${finance.totalAmountCalculated.toStringAsFixed(3)}',
                      style: const TextStyle(color: Color(0xFF666666)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _topCard(String title, String value, String emoji, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: _card,
        border: Border.all(color: const Color(0xFFD1D7DD)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF666666), fontSize: 14)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.w700, fontSize: 28)),
          const SizedBox(height: 2),
          Text(emoji, style: const TextStyle(fontSize: 32)),
        ],
      ),
    );
  }

  Widget _actionCard(String label, Color bg, Color border) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: Color(0xFF22598B))),
    );
  }
}

