import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController _authController = AuthController();
  bool _isPasswordVisible = false;

  final Map<String, Color> _palette = {
    'fondo': const Color(0xFFF8F8FA),
    'superficie': const Color(0xFFFFFFFF),
    'texto': const Color(0xFF121212),
    'secundario': const Color(0xFF546E7A),
    'marca': const Color(0xFF00236B),
    'cta': const Color(0xFF0D47A1),
    'positivo': const Color(0xFF00C853),
    'logros': const Color(0xFFC8A959),
  };

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final String? errorMessage = _authController.validateLogin();

    if (errorMessage == null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showResetPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Recuperar Contraseña", style: TextStyle(color: _palette['texto'])),
        content: Text(
          "Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu acceso.",
          style: TextStyle(color: _palette['texto']),
        ),
        backgroundColor: _palette['superficie'],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar", style: TextStyle(color: _palette['secundario'])),
          ),
          ElevatedButton(
            onPressed: () {
              // Simulación de envío
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Enlace enviado con éxito")),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _palette['cta'],
              foregroundColor: Colors.white,
            ),
            child: const Text("Enviar Enlace"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _palette['fondo'],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Text(
                "Sistema SYAC",
                style: TextStyle(
                  color: _palette['marca'],
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Calculadora Financiera",
                style: TextStyle(
                  color: _palette['secundario'],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 30),

              // Logo / Icono central
              Container(
                height: 160,
                width: 160,
                decoration: BoxDecoration(
                  color: _palette['superficie'],
                  shape: BoxShape.circle,
                  border: Border.all(color: _palette['marca']!, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Image.asset(
                      'assets/images/logo_syac.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              _buildInputField(
                controller: _authController.emailController,
                hint: "Correo Electrónico",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              _buildInputField(
                controller: _authController.passwordController,
                hint: "Contraseña",
                icon: Icons.lock_outline,
                isPassword: true,
                obscureText: !_isPasswordVisible,
                togglePassword: () {
                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                },
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _showResetPasswordDialog,
                  child: Text(
                    "¿Olvidaste tu contraseña?",
                    style: TextStyle(
                      color: _palette['cta'],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Botón Iniciar Sesión (CONECTADO A LA VALIDACIÓN)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _palette['cta'],
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text(
                    "Iniciar Sesión",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _palette['positivo']!, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text(
                    "Registrarse",
                    style: TextStyle(
                      color: _palette['positivo'],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? togglePassword,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _palette['superficie'],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(color: _palette['texto']),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: _palette['secundario']),
          prefixIcon: Icon(icon, color: _palette['marca']),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: _palette['secundario'],
                  ),
                  onPressed: togglePassword,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
    );
  }
}