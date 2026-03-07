import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/finance_controller.dart';
import 'providers/auth_provider.dart';
import 'providers/config_provider.dart';
import 'providers/calculos_provider.dart';
import 'providers/meta_provider.dart';
import 'views/splash_screen.dart';
import 'views/login_screen.dart';
import 'views/register_screen.dart';
import 'views/home_screen.dart';
import 'views/simple_interes_view.dart';
import 'views/reports_screen.dart';
import 'views/use_cases_view.dart';
import 'views/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  await authProvider.checkSession();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FinanceController()),
        ChangeNotifierProvider(create: (_) => authProvider),
        ChangeNotifierProvider(create: (_) => ConfigProvider()),
        ChangeNotifierProvider(create: (_) => CalculosProvider()),
        ChangeNotifierProvider(create: (_) => MetaProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfigProvider>(
      // NUEVO - solo para tema
      builder: (context, config, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Sistema SYAC',
          theme: config.isDarkMode ? _darkTheme : _lightTheme, // NUEVO
          initialRoute: '/splash', // Cambiado de '/login' a '/splash'
          routes: {
            '/splash': (context) => const SplashScreen(), // NUEVO
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/home': (context) => const HomeScreen(),
            '/simple': (context) => const SimpleInterestView(),
            '/reports': (context) => const ReportsScreen(),
            '/cases': (context) => const UseCasesView(),
            '/profile': (context) => const ProfileScreen(),
          },
        );
      },
    );
  }
}

// TEMAS
final _lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF00236B),
    primary: const Color(0xFF00236B),
    background: const Color(0xFFF8F8FA),
  ),
  useMaterial3: true,
);

final _darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF00236B),
    primary: const Color(0xFF00236B),
    background: const Color(0xFF121212),
  ),
  useMaterial3: true,
);
