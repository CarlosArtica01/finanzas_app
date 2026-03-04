import 'package:flutter/material.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores con nombres claros para mantenimiento
  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  // Estados de visibilidad independientes
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    // Práctica de ingeniería: liberar memoria
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Seguridad", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Actualizar Contraseña",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold, 
                  color: colorScheme.primary
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Asegúrate de usar una contraseña robusta para proteger tus datos financieros en SYAC.",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 35),

              // Sección: Contraseña Actual
              _buildPasswordField(
                context: context,
                label: "Contraseña Actual",
                controller: _currentPassController,
                isObscured: _obscureCurrent,
                onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                validator: (value) => (value == null || value.isEmpty) ? "Ingresa tu contraseña actual" : null,
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 25),
                child: Divider(thickness: 1),
              ),

              // Sección: Nueva Contraseña
              _buildPasswordField(
                context: context,
                label: "Nueva Contraseña",
                controller: _newPassController,
                isObscured: _obscureNew,
                onToggle: () => setState(() => _obscureNew = !_obscureNew),
                validator: (value) {
                  if (value == null || value.length < 8) return "Mínimo 8 caracteres";
                  if (!value.contains(RegExp(r'[A-Z]'))) return "Debe incluir una mayúscula";
                  if (!value.contains(RegExp(r'[0-9]'))) return "Debe incluir un número";
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Sección: Confirmar Contraseña
              _buildPasswordField(
                context: context,
                label: "Confirmar Nueva Contraseña",
                controller: _confirmPassController,
                isObscured: _obscureConfirm,
                onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (value) {
                  if (value != _newPassController.text) return "Las contraseñas no coinciden";
                  return null;
                },
              ),

              const SizedBox(height: 50),

              // Botón de Acción Principal
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _procesarCambio,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("Actualizar Contraseña", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required bool isObscured,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          obscureText: isObscured,
          validator: validator,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.cardColor,
            prefixIcon: Icon(Icons.lock_person_outlined, color: theme.colorScheme.primary, size: 22),
            suffixIcon: IconButton(
              icon: Icon(isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey, size: 20),
              onPressed: onToggle,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15), 
              borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.1))
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15), 
              borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.1))
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15), 
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2)
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15), 
              borderSide: const BorderSide(color: Colors.redAccent)
            ),
          ),
        ),
      ],
    );
  }

  void _procesarCambio() {
    if (_formKey.currentState!.validate()) {
      // Simulación de proceso exitoso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text("Contraseña actualizada con éxito"),
            ],
          ), 
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    }
  }
}