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
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Recuperar Contraseña", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          "Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu acceso.",
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar", style: TextStyle(color: theme.disabledColor)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Enlace enviado con éxito"), behavior: SnackBarBehavior.floating),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Text(
                "Sistema SYAC",
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Calculadora Financiera",
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // --- LOGO CENTRAL CON IMAGEN ---
              _buildLogo(colorScheme.primary, theme.cardColor),

              const SizedBox(height: 50),

              _buildInputField(
                context,
                controller: _authController.emailController,
                hint: "Correo Electrónico",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              _buildInputField(
                context,
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
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- BOTONES DE ACCIÓN ---
              _buildPrimaryButton(context, "Iniciar Sesión", _handleLogin),
              const SizedBox(height: 15),
              _buildSecondaryButton(context, "Registrarse", () {
                Navigator.pushNamed(context, '/register');
              }),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // MÉTODO MODIFICADO PARA CARGAR TU IMAGEN
  Widget _buildLogo(Color primaryColor, Color cardColor) {
    return Container(
      height: 160, width: 160,
      decoration: BoxDecoration(
        color: Colors.white, // Fondo blanco para que el logo resalte
        shape: BoxShape.circle,
        border: Border.all(color: primaryColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipOval(
        child: Padding(
          padding: const EdgeInsets.all(10.0), // Espacio para que el logo no toque los bordes
          child: Image.asset(
            'assets/images/logo_syac.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Si la imagen no carga, mostramos el icono como respaldo
              return Icon(Icons.account_balance, size: 80, color: primaryColor);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? togglePassword,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
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
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: theme.colorScheme.primary),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
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

  Widget _buildPrimaryButton(BuildContext context, String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 2,
        ),
        child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context, String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.greenAccent.shade700, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.greenAccent.shade700,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}