import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/finance_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final currentName = context.read<FinanceController>().userName;
    _nameController = TextEditingController(text: currentName);
  }

  @override
  Widget build(BuildContext context) {
    final Color colorMarca = const Color(0xFF00236B);

    return Scaffold(
      appBar: AppBar(title: const Text("Editar Información")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Nombre Completo",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<FinanceController>().updateUserName(_nameController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("¡Perfil actualizado!")),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: colorMarca),
              child: const Text("Guardar Cambios", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}