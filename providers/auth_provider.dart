import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  String _userNombre = '';
  String _userApellido = '';
  String _userEmail = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  String get userNombre => _userNombre;
  String get userApellido => _userApellido;
  String get userEmail => _userEmail;
  String get nombreCompleto => '$_userNombre $_userApellido';

  AuthProvider() {
    checkSession();
  }

  Future<void> checkSession() async {
    final isLogged = await ApiService.isLoggedIn();
    if (isLogged) {
      final userData = await ApiService.getUserData();
      _isAuthenticated = true;
      _userNombre = userData['nombre'];
      _userApellido = userData['apellido'];
      _userEmail = userData['email'];
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await ApiService.login(email, password);

    _isLoading = false;

    if (result['success']) {
      _isAuthenticated = true;
      final userData = await ApiService.getUserData();
      _userNombre = userData['nombre'];
      _userApellido = userData['apellido'];
      _userEmail = userData['email'];
      notifyListeners();
      return true;
    } else {
      _error = result['error'];
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await ApiService.register(userData);

    _isLoading = false;

    if (result['success']) {
      notifyListeners();
      return true;
    } else {
      _error = result['error'];
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile(String nombre, String apellido) async {
    final result = await ApiService.updatePerfil(nombre, apellido);
    if (result['success'] == true) {
      _userNombre = nombre;
      _userApellido = apellido;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await ApiService.logout();
    _isAuthenticated = false;
    _userNombre = '';
    _userApellido = '';
    _userEmail = '';
    notifyListeners();
  }
}