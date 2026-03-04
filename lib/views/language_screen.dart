import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/finance_controller.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Idioma", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<FinanceController>(
        builder: (context, finance, child) {
          return ListView(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5, bottom: 15),
                child: Text(
                  "SELECCIONA TU IDIOMA", 
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.grey, 
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              
              _LanguageOption(
                name: "Español", 
                code: "es", 
                flag: "🇪🇸", 
                isSelected: finance.currentLanguage == "Español",
                onTap: () => _handleLanguageChange(context, finance, "Español"),
              ),
              
              _LanguageOption(
                name: "English", 
                code: "en", 
                flag: "🇺🇸", 
                isSelected: finance.currentLanguage == "English",
                onTap: () => _handleLanguageChange(context, finance, "English"),
              ),
              
              const SizedBox(height: 30),
              
              // --- NOTA INFORMATIVA ADAPTATIVA ---
              Card(
                elevation: 0,
                color: theme.cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.grey, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Nota: Al cambiar el idioma, algunos reportes podrían tardar unos segundos en actualizar su formato.",
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  void _handleLanguageChange(BuildContext context, FinanceController finance, String language) {
    // Llamada al método asíncrono del controlador
    finance.updateLanguage(language);
    
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Idioma cambiado a $language"), 
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

// --- COMPONENTE DE OPCIÓN DE IDIOMA ---

class _LanguageOption extends StatelessWidget {
  final String name;
  final String code;
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.name,
    required this.code,
    required this.flag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorPrimary = theme.colorScheme.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        border: isSelected 
          ? Border.all(color: colorPrimary, width: 2) 
          : Border.all(color: theme.dividerColor.withOpacity(0.1)),
        boxShadow: isSelected 
          ? [BoxShadow(color: colorPrimary.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))] 
          : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.transparent,
          child: Text(flag, style: const TextStyle(fontSize: 24)),
        ),
        title: Text(
          name, 
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? colorPrimary : theme.textTheme.bodyLarge?.color,
          )
        ),
        trailing: isSelected 
          ? Icon(Icons.check_circle, color: colorPrimary) 
          : Icon(Icons.circle_outlined, color: theme.dividerColor.withOpacity(0.3)),
        onTap: onTap,
      ),
    );
  }
}