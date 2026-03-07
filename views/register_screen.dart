import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthController _authController = AuthController();
  bool _acceptTerms = false;

  final Color _bg = const Color(0xFFF5F5F5);
  final Color _brand = const Color(0xFF254E81);
  final Color _border = const Color(0xFFD5DCE3);
  final Color _register = const Color(0xFF8EE09E);

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final error = _authController.validateRegister(_acceptTerms);
    if (error != null) {
      _showSnack(error, true);
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final userData = {
      'nombre': _authController.nameController.text.trim(),
      'apellido': _authController.lastNameController.text.trim(),
      'correo': _authController.emailController.text.trim(),
      'password': _authController.passwordController.text,
    };

    final success = await authProvider.register(userData);
    if (!mounted) return;

    if (success) {
      _showSnack('Registro exitoso. Ahora inicia sesión', false);
      Navigator.pop(context);
      return;
    }

    _showSnack(authProvider.error ?? 'Error en registro', true);
  }

  void _showSnack(String text, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF1FA750),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 360),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(alignment: Alignment.centerLeft, padding: EdgeInsets.zero),
                    child: const Text('< Volver', style: TextStyle(color: Color(0xFF9CC8F3), fontSize: 22)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Registro en\nSistema SYAC',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _brand,
                      fontWeight: FontWeight.w800,
                      fontSize: 38,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _field(_authController.nameController, 'Nombre', Icons.person),
                  const SizedBox(height: 11),
                  _field(_authController.lastNameController, 'Apellido', Icons.person),
                  const SizedBox(height: 11),
                  _field(_authController.emailController, 'Correo electrónico', Icons.email),
                  const SizedBox(height: 11),
                  _field(_authController.passwordController, 'Contraseña', Icons.lock, isPassword: true),
                  const SizedBox(height: 11),
                  _field(
                    _authController.confirmPasswordController,
                    'Confirmar contraseña',
                    Icons.lock,
                    isPassword: true,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: _acceptTerms,
                        onChanged: (value) => setState(() => _acceptTerms = value ?? false),
                      ),
                      const Expanded(
                        child: Text('Acepto términos y condiciones', style: TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _register,
                      foregroundColor: const Color(0xFF1D8C42),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    child: const Text('Registrarse'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF2D7CCC)),
        filled: true,
        fillColor: const Color(0xFFF0F0F0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _brand),
        ),
      ),
    );
  }
}

