import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class ConfigProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _notificaciones = true;

  bool get isDarkMode => _isDarkMode;
  bool get notificaciones => _notificaciones;

  ConfigProvider() {
    loadConfig();
  }

  Future<void> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _notificaciones = prefs.getBool('notificaciones') ?? true;
    if (await ApiService.isLoggedIn()) {
      final result = await ApiService.getConfiguracion();
      if (result['success'] == true && result['data'] != null) {
        final d = result['data'] as Map<String, dynamic>;
        _isDarkMode = (d['tema']?.toString().toLowerCase() ?? 'claro') == 'oscuro';
        _notificaciones = d['notificaciones_activas'] == true || d['notificaciones_activas'] == 1;
        await prefs.setBool('isDarkMode', _isDarkMode);
        await prefs.setBool('notificaciones', _notificaciones);
      }
    }
    notifyListeners();
  }

  Future<void> toggleTema() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    if (await ApiService.isLoggedIn()) {
      await ApiService.updateConfiguracion(
        tema: _isDarkMode ? 'Oscuro' : 'Claro',
      );
    }
    notifyListeners();
  }

  Future<void> toggleNotificaciones(bool valor) async {
    _notificaciones = valor;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificaciones', valor);
    if (await ApiService.isLoggedIn()) {
      await ApiService.updateConfiguracion(notificacionesActivas: valor);
    }
    notifyListeners();
  }
}