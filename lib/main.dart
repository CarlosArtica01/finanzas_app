import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importación necesaria para WidgetsFlutterBinding
import 'package:flutter/widgets.dart';

// Importación de controladores
import 'controllers/finance_controller.dart';

// Importación de vistas
import 'views/login_screen.dart';
import 'views/register_screen.dart';
import 'views/home_screen.dart';
import 'views/simple_interes_view.dart';
import 'views/reports_screen.dart';
import 'views/use_cases_view.dart'; 
import 'views/profile_screen.dart';
import 'views/notifications_screen.dart';
import 'views/language_screen.dart';

void main() async {
  // 1. Vinculación obligatoria para SharedPreferences y servicios nativos
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiProvider(
      providers: [
        // 2. Inyección del controlador. Asegúrate de que FinanceController 
        // cargue sus preferencias en un método init separado, no solo en el constructor.
        ChangeNotifierProvider(create: (_) => FinanceController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color colorMarca = Color(0xFF00236B);

    return Consumer<FinanceController>(
      builder: (context, finance, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Sistema SYAC',
          
          // --- CONFIGURACIÓN DE TEMAS DINÁMICOS ---
          themeMode: finance.themeMode, 

          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: colorMarca,
              primary: colorMarca,
              surface: const Color(0xFFF8F8FA),
            ),
            scaffoldBackgroundColor: const Color(0xFFF8F8FA),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: colorMarca,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: colorMarca),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: colorMarca,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: colorMarca,
              brightness: Brightness.dark,
              primary: colorMarca,
              surface: const Color(0xFF121212),
            ),
            scaffoldBackgroundColor: const Color(0xFF121212),
            cardColor: const Color(0xFF1E1E1E),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: colorMarca,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          initialRoute: '/login',
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/home': (context) => const HomeScreen(),
            '/simple': (context) => const SimpleInterestView(),
            '/reports': (context) => const ReportsScreen(),
            '/cases': (context) => const UseCasesView(),
            '/profile': (context) => const ProfileScreen(),
            '/notifications': (context) => const NotificationsScreen(),
            '/language': (context) => const LanguageScreen(),
          },
        );
      },
    );
  }
}