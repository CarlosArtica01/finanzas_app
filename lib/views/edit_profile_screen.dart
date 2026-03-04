import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/finance_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _roleController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final finance = Provider.of<FinanceController>(context, listen: false);
    _nameController = TextEditingController(text: finance.userName);
    _roleController = TextEditingController(text: finance.userRole);
    _emailController = TextEditingController(text: finance.userEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _mostrarOpcionesImagen(BuildContext context, FinanceController finance) {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Foto de Perfil", 
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.photo_library, color: theme.colorScheme.primary),
                title: const Text("Galería"),
                onTap: () {
                  finance.seleccionarImagen(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: theme.colorScheme.primary),
                title: const Text("Cámara"),
                onTap: () {
                  finance.seleccionarImagen(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _guardarCambios(FinanceController finance) {
    finance.updateFullProfile(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _roleController.text.trim(),
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Perfil actualizado correctamente"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<FinanceController>(
      builder: (context, finance, child) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text("Editar Perfil", style: TextStyle(fontWeight: FontWeight.bold)),
            elevation: 0,
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: () => _guardarCambios(finance),
              )
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Column(
              children: [
                _buildProfileAvatar(finance, colorScheme.primary),
                const SizedBox(height: 40),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      _EditField(
                        label: "Nombre Completo", 
                        controller: _nameController, 
                        icon: Icons.person_outline
                      ),
                      const SizedBox(height: 20),
                      _EditField(
                        label: "Ocupación / Rol", 
                        controller: _roleController, 
                        icon: Icons.work_outline
                      ),
                      const SizedBox(height: 20),
                      _EditField(
                        label: "Correo Electrónico", 
                        controller: _emailController, 
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                _buildSaveButton(finance, colorScheme.primary),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileAvatar(FinanceController finance, Color primaryColor) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 65,
            backgroundColor: primaryColor.withValues(alpha: 0.1),
            backgroundImage: finance.imageFile != null 
                ? FileImage(finance.imageFile!) 
                : null,
            child: finance.imageFile == null 
                ? Icon(Icons.person, size: 65, color: primaryColor) 
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: FloatingActionButton.small(
              heroTag: 'camera_btn',
              onPressed: () => _mostrarOpcionesImagen(context, finance),
              backgroundColor: primaryColor,
              child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(FinanceController finance, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: () => _guardarCambios(finance),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 2,
          ),
          child: const Text("Guardar Cambios", 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboardType;

  const _EditField({
    required this.label, 
    required this.controller, 
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, 
          style: theme.textTheme.labelMedium?.copyWith(
            color: Colors.grey, 
            fontWeight: FontWeight.bold
          )
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: theme.colorScheme.primary),
            filled: true,
            fillColor: theme.cardColor,
            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
            ),
          ),
        ),
      ],
    );
  }
}