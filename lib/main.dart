import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/finance_controller.dart';
import 'views/login_screen.dart';
import 'views/register_screen.dart';
import 'views/home_screen.dart';
import 'views/simple_interes_view.dart';
import 'views/reports_screen.dart';
import 'views/use_cases_view.dart'; 

void main() {
  runApp(
    // Envolvemos la app con el Provider para que el FinanceController
    // esté disponible en todas las pantallas.
    MultiProvider(
      providers: [
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistema SYAC',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00236B),
          primary: const Color(0xFF00236B),
        ),
        useMaterial3: true,
        // Estilo global para botones para mantener la estética SYAC
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF00236B),
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
        '/cases': (context) => const UseCasesView(), // Ruta de Casos de Uso
      },
    );
  }
}