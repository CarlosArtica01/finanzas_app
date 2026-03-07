import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController _authController = AuthController();

  final Color _bg = const Color(0xFFF5F5F5);
  final Color _brand = const Color(0xFF254E81);
  final Color _border = const Color(0xFFD5DCE3);
  final Color _loginBtn = const Color(0xFF8BC0EA);
  final Color _register = const Color(0xFF8EE09E);

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final errorMessage = _authController.validateLogin();
    if (errorMessage != null) {
      _showSnack(errorMessage, isError: true);
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _authController.emailController.text.trim(),
      _authController.passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
      return;
    }

    _showSnack(authProvider.error ?? 'Error al iniciar sesión', isError: true);
  }

  Future<void> _showResetPasswordDialog() async {
    final emailController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Recuperar contraseña'),
        content: TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'Correo electrónico',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty) {
                _showSnack('Ingresa un correo', isError: true);
                return;
              }

              Navigator.pop(context);
              final result = await ApiService.forgotPassword(email);
              if (!mounted) return;

              _showSnack(
                result['mensaje'] ?? 'Revisa tu correo electrónico',
                isError: result['success'] != true,
              );
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  void _showSnack(String text, {required bool isError}) {
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
              padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Sistema SYAC',
                    style: TextStyle(
                      color: _brand,
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Calculadora Financiera',
                    style: TextStyle(color: Color(0xFF5D5D5D), fontSize: 25),
                  ),
                  const SizedBox(height: 26),
                  Container(
                    width: 145,
                    height: 145,
                    decoration: BoxDecoration(
                      color: const Color(0xFF97CBEF),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF5CADED), width: 4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Image.asset('assets/images/logo_syac.png', fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _field(_authController.emailController, 'Usuario', Icons.person, false),
                  const SizedBox(height: 12),
                  _field(_authController.passwordController, 'Contraseña', Icons.lock, true),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _showResetPasswordDialog,
                      child: const Text('¿Olvidaste tu contraseña?'),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _loginBtn,
                        foregroundColor: const Color(0xFF145897),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      child: const Text('Iniciar Sesión'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pushNamed(context, '/register'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: _register, width: 3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: const Color(0xFF229648),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      child: const Text('Registrarse'),
                    ),
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
    IconData icon,
    bool isPassword,
  ) {
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

