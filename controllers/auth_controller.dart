import 'package:flutter/material.dart';

class AuthController {
  // --- Controladores para Login ---
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // --- Controladores adicionales para Registro ---
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();

  // --- Estado de Fecha ---
  DateTime? selectedDate;

  // --- 1. VALIDACIONES DE FORMATO ---

  /// Verifica si el correo tiene un formato válido (ejemplo@dominio.com)
  bool isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  /// Calcula la fortaleza de la contraseña de 0.0 a 1.0
  double checkPasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    double strength = 0;

    if (password.length >= 8) strength += 0.3; // Longitud
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.3; // Mayúsculas
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2; // Números
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.2; // Especiales
    
    return strength;
  }

  /// Verifica si el usuario tiene al menos 18 años
  bool isAdult() {
    if (selectedDate == null) return false;
    final now = DateTime.now();
    int age = now.year - selectedDate!.year;
    
    // Ajuste por si no ha pasado su cumpleaños este año
    if (now.month < selectedDate!.month || 
       (now.month == selectedDate!.month && now.day < selectedDate!.day)) {
      age--;
    }
    return age >= 18;
  }

  // --- 2. LÓGICA DE VALIDACIÓN DE FORMULARIOS ---

  /// Validación para la pantalla de Login
  String? validateLogin() {
    final email = emailController.text.trim();
    final pass = passwordController.text.trim();

    if (email.isEmpty || pass.isEmpty) return "Todos los campos son obligatorios";
    if (!isValidEmail(email)) return "El correo electrónico no es válido";
    if (pass.length < 6) return "La contraseña debe tener al menos 6 caracteres";
    
    return null; // Todo correcto
  }

  /// Validación para la pantalla de Registro
  String? validateRegister(bool termsAccepted) {
    if (nameController.text.trim().isEmpty || lastNameController.text.trim().isEmpty) {
      return "Nombre y apellido son obligatorios";
    }
    
    if (!isValidEmail(emailController.text.trim())) {
      return "Ingresa un correo electrónico válido";
    }

    if (checkPasswordStrength(passwordController.text) < 0.6) {
      return "La contraseña es muy débil (usa mayúsculas y números)";
    }

    if (passwordController.text != confirmPasswordController.text) {
      return "Las contraseñas no coinciden";
    }

    if (!termsAccepted) {
      return "Debes aceptar los términos y condiciones";
    }

    return null; // Todo correcto
  }

  // --- 3. GESTIÓN DE MEMORIA ---

  /// Limpia los controladores al cerrar la pantalla para evitar fugas de memoria
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    lastNameController.dispose();
    confirmPasswordController.dispose();
    birthDateController.dispose();
  }
}
