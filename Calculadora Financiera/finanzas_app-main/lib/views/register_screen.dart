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

  final Color colorMarca = const Color(0xFF00236B);
  final Color colorPositivo = const Color(0xFF00C853);
  final Color colorFondo = const Color(0xFFF8F8FA);

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorMarca),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Volver", style: TextStyle(color: colorMarca, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            Text(
              "Registro en\nSistema SYAC",
              textAlign: TextAlign.center,
              style: TextStyle(color: colorMarca, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            _buildField(_authController.nameController, "Nombre", Icons.person_outline),
            const SizedBox(height: 15),
            _buildField(_authController.lastNameController, "Apellido", Icons.person_outline),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2005),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    _authController.selectedDate = picked;
                    _authController.birthDateController.text =
                        "${picked.day}/${picked.month}/${picked.year}";
                  });
                }
              },
              child: AbsorbPointer(
                child: _buildField(
                    _authController.birthDateController, "Fecha de nacimiento", Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 15),
            _buildField(
                _authController.emailController, "Correo electrónico", Icons.email_outlined),
            const SizedBox(height: 15),
            _buildField(_authController.passwordController, "Contraseña", Icons.lock_outline,
                isPassword: true, onChanged: (_) => setState(() {})),
            LinearProgressIndicator(
              value: _authController.checkPasswordStrength(_authController.passwordController.text),
              color: _authController.checkPasswordStrength(_authController.passwordController.text) < 0.6
                  ? Colors.orange
                  : Colors.green,
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(height: 15),
            _buildField(_authController.confirmPasswordController, "Confirmar contraseña",
                Icons.lock_reset, isPassword: true),
            Row(
              children: [
                Checkbox(
                  value: _acceptTerms,
                  activeColor: colorPositivo,
                  onChanged: (val) => setState(() => _acceptTerms = val ?? false),
                ),
                const Expanded(
                    child: Text("Acepto términos y condiciones", style: TextStyle(fontSize: 13))),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () async {
                  final String? error = _authController.validateRegister(_acceptTerms);
                  if (error == null) {
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    final userData = {
                      'nombre': _authController.nameController.text.trim(),
                      'apellido': _authController.lastNameController.text.trim(),
                      'correo': _authController.emailController.text.trim(),
                      'password': _authController.passwordController.text,
                    };
                    final bool success = await authProvider.register(userData);
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Registro exitoso. Ahora inicia sesión"),
                            backgroundColor: Colors.green),
                      );
                      Navigator.pop(context);
                    } else if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(authProvider.error ?? 'Error en registro'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error), backgroundColor: Colors.red),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorPositivo.withOpacity(0.2),
                  foregroundColor: colorPositivo,
                  side: BorderSide(color: colorPositivo),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("Registrarse",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String hint, IconData icon,
      {bool isPassword = false, Function(String)? onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: colorMarca),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(15),
        ),
      ),
    );
  }
}
