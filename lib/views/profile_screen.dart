import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/finance_controller.dart';
import 'edit_profile_screen.dart';
import 'security_screen.dart';
import 'notifications_screen.dart';
import 'language_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<FinanceController>(
      builder: (context, finance, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Mi Perfil", style: TextStyle(fontWeight: FontWeight.bold)),
            elevation: 0,
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 30),
                
                // --- CABECERA DE PERFIL ---
                _buildProfileHeader(context, finance, isDark),
                
                const SizedBox(height: 40),

                // --- SECCIÓN: CUENTA ---
                _buildSectionTitle(context, "Cuenta"),
                _buildSettingsItem(
                  context,
                  Icons.person_outline, 
                  "Información Personal", 
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                ),
                _buildSettingsItem(
                  context,
                  Icons.security_outlined, 
                  "Seguridad y Contraseña", 
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityScreen())),
                ),
                
                const SizedBox(height: 20),
                
                // --- SECCIÓN: PREFERENCIAS ---
                _buildSectionTitle(context, "Preferencias"),
                _buildSettingsItem(
                  context,
                  Icons.notifications_none_outlined, 
                  "Notificaciones", 
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                ),
                _buildSettingsItem(
                  context,
                  Icons.language_outlined, 
                  "Idioma", 
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LanguageScreen())),
                ),

                // --- ITEM: MODO OSCURO ---
                _buildThemeSwitch(context, finance),

                const SizedBox(height: 35),
                
                // --- BOTÓN CERRAR SESIÓN ---
                _buildLogoutButton(context, isDark),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, FinanceController finance, bool isDark) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primaryColor.withValues(alpha: 0.2), width: 2),
            ),
            child: CircleAvatar(
              radius: 55,
              backgroundColor: primaryColor.withValues(alpha: 0.1),
              backgroundImage: finance.imageFile != null ? FileImage(finance.imageFile!) : null,
              child: finance.imageFile == null 
                  ? Icon(Icons.person, size: 55, color: primaryColor) 
                  : null,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            finance.userName, 
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 4),
          Text(
            finance.userRole,
            style: TextStyle(
              color: isDark ? Colors.blue[200] : primaryColor, 
              fontWeight: FontWeight.w600, 
              fontSize: 14
            ),
          ),
          Text(
            finance.userEmail, 
            style: const TextStyle(color: Colors.grey, fontSize: 13)
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSwitch(BuildContext context, FinanceController finance) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        leading: Icon(
          finance.isDarkMode ? Icons.dark_mode : Icons.light_mode_outlined, 
          color: theme.colorScheme.primary
        ),
        title: const Text("Modo Oscuro", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
        trailing: Switch.adaptive(
          value: finance.isDarkMode,
          activeColor: theme.colorScheme.primary,
          onChanged: (value) => finance.toggleTheme(value),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListTile(
        onTap: () => _mostrarDialogoCerrarSesion(context),
        tileColor: isDark ? Colors.red.withValues(alpha: 0.1) : Colors.red[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        leading: const Icon(Icons.logout_rounded, color: Colors.red),
        title: const Text(
          "Cerrar Sesión", 
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(), 
          style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.1)
        ),
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  void _mostrarDialogoCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("¿Cerrar Sesión?"),
        content: const Text("¿Estás seguro de que deseas salir del Sistema SYAC?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text("Cancelar", style: TextStyle(color: Theme.of(context).disabledColor))
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0
            ),
            child: const Text("Salir"),
          ),
        ],
      ),
    );
  }
}