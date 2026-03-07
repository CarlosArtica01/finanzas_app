import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/config_provider.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color _brand = Color(0xFF254E81);

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfigProvider>(
      builder: (context, config, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Ajustes',
                      style: TextStyle(color: _brand, fontWeight: FontWeight.w700, fontSize: 30),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _card(
                    child: const ListTile(
                      leading: Text('??', style: TextStyle(fontSize: 18)),
                      title: Text('Moneda'),
                      subtitle: Text('Lempiras (HNL)'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _card(
                    child: ListTile(
                      leading: const Text('??', style: TextStyle(fontSize: 18)),
                      title: const Text('Tema'),
                      trailing: _themeSwitch(context, config),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _card(
                    child: ListTile(
                      leading: const Text('??', style: TextStyle(fontSize: 18)),
                      title: const Text('Notificaciones'),
                      trailing: Switch(
                        value: config.notificaciones,
                        onChanged: (v) => config.toggleNotificaciones(v),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _card(
                    child: ListTile(
                      leading: const Text('??', style: TextStyle(fontSize: 18)),
                      title: const Text('Cambiar contraseña ?'),
                      onTap: () => _showChangePasswordDialog(context),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _card(
                    child: const ListTile(
                      title: Text('Información', style: TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('Sistema SYAC v1.0 - Calculadora\nFinanciera Honduras'),
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

  Widget _themeSwitch(BuildContext context, ConfigProvider config) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD9DEE3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              if (!config.isDarkMode) return;
              config.toggleTema();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: config.isDarkMode ? Colors.transparent : const Color(0xFF8CC1EB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Claro'),
            ),
          ),
          InkWell(
            onTap: () {
              if (config.isDarkMode) return;
              config.toggleTema();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: config.isDarkMode ? const Color(0xFF8CC1EB) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Oscuro'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        border: Border.all(color: const Color(0xFFD1D7DD)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final currentController = TextEditingController();
    final newController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cambiar contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña actual'),
            ),
            TextField(
              controller: newController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Nueva contraseña'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final result = await ApiService.changePassword(
                currentController.text.trim(),
                newController.text.trim(),
              );
              if (!context.mounted) return;
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result['success'] == true ? 'Contraseña actualizada' : (result['error'] ?? 'Error')),
                  backgroundColor: result['success'] == true ? const Color(0xFF1FA750) : Colors.redAccent,
                ),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

