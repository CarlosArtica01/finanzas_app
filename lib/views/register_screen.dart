import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Inicializamos el controlador reactivo
  final AuthController _authController = AuthController();
  bool _acceptTerms = false;

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Volver", 
          style: TextStyle(color: colorScheme.primary, fontSize: 16)
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              "Registro en\nSistema SYAC", 
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: colorScheme.primary, 
                fontWeight: FontWeight.bold
              )
            ),
            const SizedBox(height: 30),
            
            _buildField(context, _authController.nameController, "Nombre", Icons.person_outline),
            const SizedBox(height: 15),
            _buildField(context, _authController.lastNameController, "Apellido", Icons.person_outline),
            const SizedBox(height: 15),
            
            // Selector de Fecha (Lógica centralizada en el controlador)
            GestureDetector(
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().subtract(const Duration(days: 6570)), // ~18 años atrás
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  _authController.selectedDate = picked;
                }
              },
              child: AbsorbPointer(
                child: ListenableBuilder(
                  listenable: _authController,
                  builder: (context, _) {
                    return _buildField(
                      context, 
                      _authController.birthDateController, 
                      "Fecha de nacimiento", 
                      Icons.calendar_today_outlined
                    );
                  }
                ),
              ),
            ),
            const SizedBox(height: 15),

            _buildField(context, _authController.emailController, "Correo electrónico", Icons.email_outlined, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 15),

            // Password + Strength Indicator Reactivo
            ListenableBuilder(
              listenable: _authController,
              builder: (context, _) => _buildPasswordField(context),
            ),
            const SizedBox(height: 15),

            _buildField(context, _authController.confirmPasswordController, "Confirmar contraseña", Icons.lock_reset_outlined, isPassword: true),
            
            _buildTermsCheckbox(context),
            
            const SizedBox(height: 30),
            _buildRegisterButton(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    // Acceso al getter reactivo del controlador
    double strength = _authController.passwordStrength;
    Color strengthColor = strength < 0.4 
        ? Colors.red 
        : (strength < 0.7 ? Colors.orange : Colors.green);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildField(
          context, 
          _authController.passwordController, 
          "Contraseña", 
          Icons.lock_outline, 
          isPassword: true, 
          onChanged: (v) => _authController.notifyListeners() // Forzamos actualización local
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: strength,
              color: strengthColor,
              backgroundColor: Theme.of(context).dividerColor.withOpacity(0.1),
              minHeight: 6,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 5),
          child: Text(
            strength < 0.4 ? "Contraseña débil" : (strength < 0.7 ? "Seguridad media" : "Contraseña segura"),
            style: TextStyle(fontSize: 12, color: strengthColor, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: _acceptTerms, 
          activeColor: Colors.green, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: (val) => setState(() => _acceptTerms = val!)
        ),
        const Expanded(
          child: Text("Acepto los términos y condiciones de uso."),
        ),
      ],
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return SizedBox(
      width: double.infinity, 
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          String? error = _authController.validateRegister(_acceptTerms);
          if (error == null) {
            // Aquí iría la lógica de guardado real
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error), 
                backgroundColor: Colors.redAccent, 
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              )
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.withOpacity(0.1),
          foregroundColor: Colors.green,
          elevation: 0,
          side: const BorderSide(color: Colors.green, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: const Text("Crear Cuenta", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildField(BuildContext context, TextEditingController controller, String hint, IconData icon, {bool isPassword = false, Function(String)? onChanged, TextInputType keyboardType = TextInputType.text}) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: theme.cardColor, 
        borderRadius: BorderRadius.circular(12), 
        border: Border.all(color: theme.dividerColor.withOpacity(0.1))
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        onChanged: onChanged,
        keyboardType: keyboardType,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: hint, 
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(icon, color: theme.colorScheme.primary), 
          border: InputBorder.none, 
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20)
        ),
      ),
    );
  }
}