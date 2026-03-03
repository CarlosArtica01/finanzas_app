import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color colorMarca = const Color(0xFF00236B);

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
            // Cabecera del Perfil
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: colorMarca.withOpacity(0.1),
                    child: Icon(Icons.person, size: 50, color: colorMarca),
                  ),
                  const SizedBox(height: 15),
                  const Text("Usuario SYAC", 
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const Text("usuario@syac.com", 
                    style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Opciones de Ajustes
            _buildSectionTitle("Cuenta"),
            _buildSettingsItem(
              Icons.person_outline, 
              "Información Personal", 
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                );
              }
            ),
            _buildSettingsItem(Icons.security, "Seguridad y Contraseña", () {}),
            
            const SizedBox(height: 20),
            _buildSectionTitle("Preferencias"),
            _buildSettingsItem(Icons.notifications_none, "Notificaciones", () {}),
            _buildSettingsItem(Icons.language, "Idioma", () {}),
            _buildSettingsItem(Icons.dark_mode_outlined, "Modo Oscuro", () {}),

            const SizedBox(height: 30),
            // Botón Cerrar Sesión
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListTile(
                onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false),
                tileColor: Colors.red[50],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Cerrar Sesión", 
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, 
          style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF00236B)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}