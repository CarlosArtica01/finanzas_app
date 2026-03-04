import 'package:flutter/material.dart';

class AuthController extends ChangeNotifier {
  // --- Controladores para Login ---
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // --- Controladores adicionales para Registro ---
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();

  // --- Estado Interno Reactivo ---
  DateTime? _selectedDate;
  DateTime? get selectedDate => _selectedDate;

  set selectedDate(DateTime? date) {
    _selectedDate = date;
    if (date != null) {
      birthDateController.text = "${date.day}/${date.month}/${date.year}";
    }
    notifyListeners(); // Notifica a la UI para actualizar validaciones
  }

  // --- 1. VALIDACIONES DE FORMATO ---

  /// Verifica si el correo tiene un formato válido
  bool isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email.trim());
  }

  /// Calcula la fortaleza de la contraseña (0.0 a 1.0)
  double get passwordStrength {
    final password = passwordController.text;
    if (password.isEmpty) return 0.0;
    double strength = 0;

    if (password.length >= 8) strength += 0.3;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.3;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.2;
    
    return strength;
  }

  /// Verifica la mayoría de edad (18+)
  bool isAdult() {
    if (_selectedDate == null) return false;
    final now = DateTime.now();
    int age = now.year - _selectedDate!.year;
    
    if (now.month < _selectedDate!.month || 
       (now.month == _selectedDate!.month && now.day < _selectedDate!.day)) {
      age--;
    }
    return age >= 18;
  }

  // --- 2. LÓGICA DE VALIDACIÓN ---

  String? validateLogin() {
    final email = emailController.text.trim();
    final pass = passwordController.text;

    if (email.isEmpty || pass.isEmpty) return "Todos los campos son obligatorios";
    if (!isValidEmail(email)) return "Formato de correo inválido";
    if (pass.length < 6) return "La contraseña debe tener al menos 6 caracteres";
    
    return null;
  }

  String? validateRegister(bool termsAccepted) {
    if (nameController.text.trim().isEmpty || lastNameController.text.trim().isEmpty) {
      return "Nombre y apellido son requeridos";
    }
    
    if (!isValidEmail(emailController.text)) {
      return "Ingresa un correo electrónico válido";
    }

    if (_selectedDate == null) return "La fecha de nacimiento es obligatoria";
    if (!isAdult()) return "Debes ser mayor de 18 años";
    if (passwordStrength < 0.6) return "La contraseña no es suficientemente segura";

    if (passwordController.text != confirmPasswordController.text) {
      return "Las contraseñas no coinciden";
    }

    if (!termsAccepted) return "Debes aceptar los términos y condiciones";

    return null;
  }

  // --- 3. GESTIÓN DE RECURSOS ---

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    lastNameController.dispose();
    confirmPasswordController.dispose();
    birthDateController.dispose();
    super.dispose();
  }
}