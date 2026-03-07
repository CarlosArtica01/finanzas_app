import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/config_provider.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color colorMarca = Color(0xFF00236B);

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ConfigProvider>(
      builder: (context, auth, config, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F8FA),
          appBar: AppBar(
            title: const Text("Mi Perfil", style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white,
            foregroundColor: colorMarca,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: colorMarca.withOpacity(0.1),
                        child: const Icon(Icons.person, size: 50, color: colorMarca),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        auth.userNombre.isEmpty && auth.userApellido.isEmpty
                            ? "Usuario SYAC"
                            : "${auth.userNombre} ${auth.userApellido}".trim(),
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        auth.userEmail.isEmpty ? "usuario@syac.com" : auth.userEmail,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                _buildSectionTitle("Cuenta"),
                _buildSettingsItem(
                  context,
                  Icons.person_outline,
                  "Información Personal",
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                  ),
                ),
                _buildSettingsItem(context, Icons.security, "Seguridad y Contraseña", () {}),
                const SizedBox(height: 20),
                _buildSectionTitle("Preferencias"),
                _buildSettingsItem(
                  context,
                  Icons.notifications_none,
                  "Notificaciones",
                  () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Notificaciones"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("¿Activar notificaciones?"),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    await config.toggleNotificaciones(true);
                                    if (context.mounted) Navigator.pop(context);
                                  },
                                  child: const Text("Sí"),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    await config.toggleNotificaciones(false);
                                    if (context.mounted) Navigator.pop(context);
                                  },
                                  child: const Text("No"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                _buildSettingsItem(
                  context,
                  Icons.dark_mode_outlined,
                  config.isDarkMode ? "Modo Claro" : "Modo Oscuro",
                  () async => await config.toggleTema(),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListTile(
                    onTap: () async {
                      await Provider.of<AuthProvider>(context, listen: false).logout();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                      }
                    },
                    tileColor: Colors.red[50],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      "Cerrar Sesión",
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: colorMarca),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
