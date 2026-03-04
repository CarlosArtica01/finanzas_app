import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart'; // Necesario para guardar la imagen permanentemente
import '../models/case_model.dart';

enum AccountType { efectivo, banco, ahorros }
enum TransactionType { ingreso, gasto }

class FinanceController extends ChangeNotifier {
  // --- CLAVES DE PERSISTENCIA (ETL Keys) ---
  static const String _keyName = "user_name";
  static const String _keyRole = "user_role";
  static const String _keyEmail = "user_email";
  static const String _keyLang = "app_language";
  static const String _keyTheme = "is_dark_mode";
  static const String _keyImgPath = "profile_image_path";
  static const String _keyNotifGasto = "notif_gasto";
  static const String _keyNotifAhorro = "notif_ahorro";
  static const String _keyNotifSeg = "notif_seguridad";

  // --- PROPIEDADES DE USUARIO ---
  String _userName = "Carlos Bayardo Artica";
  String _userEmail = "carlos.artica@unah.edu.hn";
  String _userRole = "Data Analyst";
  File? _imageFile;
  SharedPreferences? _prefs; // Instancia única para evitar Channel Errors

  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userRole => _userRole;
  File? get imageFile => _imageFile;

  final ImagePicker _picker = ImagePicker();

  // --- PREFERENCIAS DE APP ---
  String _currentLanguage = "Español";
  ThemeMode _themeMode = ThemeMode.light;
  bool _notifyGastoExcesivo = true;
  bool _notifyRecordatorioAhorro = false;
  bool _notifySeguridad = true;

  String get currentLanguage => _currentLanguage;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get notifyGastoExcesivo => _notifyGastoExcesivo;
  bool get notifyRecordatorioAhorro => _notifyRecordatorioAhorro;
  bool get notifySeguridad => _notifySeguridad;

  // --- MODELO FINANCIERO ---
  double saldoEfectivo = 0.0;
  double saldoBanco = 0.0;
  double saldoAhorros = 2500.0;
  final List<Map<String, dynamic>> _movimientos = [];
  
  List<Map<String, dynamic>> get movimientos => _movimientos;
  double get saldoTotalGeneral => saldoEfectivo + saldoBanco + saldoAhorros;

  FinanceController() {
    _initStorage();
  }

  /// Inicializa la persistencia de datos (Data Hydration)
  Future<void> _initStorage() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      
      _userName = _prefs?.getString(_keyName) ?? _userName;
      _userRole = _prefs?.getString(_keyRole) ?? _userRole;
      _userEmail = _prefs?.getString(_keyEmail) ?? _userEmail;
      _currentLanguage = _prefs?.getString(_keyLang) ?? "Español";
      
      final isDark = _prefs?.getBool(_keyTheme) ?? false;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

      _notifyGastoExcesivo = _prefs?.getBool(_keyNotifGasto) ?? true;
      _notifyRecordatorioAhorro = _prefs?.getBool(_keyNotifAhorro) ?? false;
      _notifySeguridad = _prefs?.getBool(_keyNotifSeg) ?? true;

      String? imagePath = _prefs?.getString(_keyImgPath);
      if (imagePath != null && await File(imagePath).exists()) {
        _imageFile = File(imagePath);
      }

      notifyListeners();
    } catch (e) {
      debugPrint("SYAC Persistence Error: $e");
    }
  }

  // --- MÉTODOS DE ACTUALIZACIÓN ---

  Future<void> updateLanguage(String language) async {
    _currentLanguage = language;
    notifyListeners();
    await _prefs?.setString(_keyLang, language);
  }

  Future<void> toggleNotification(String type, bool value) async {
    if (value) {
      PermissionStatus status = await Permission.notification.request();
      if (!status.isGranted) return; 
    }

    if (type == 'gasto') {
      _notifyGastoExcesivo = value;
      await _prefs?.setBool(_keyNotifGasto, value);
    } else if (type == 'ahorro') {
      _notifyRecordatorioAhorro = value;
      await _prefs?.setBool(_keyNotifAhorro, value);
    } else if (type == 'seguridad') {
      _notifySeguridad = value;
      await _prefs?.setBool(_keyNotifSeg, value);
    }
    notifyListeners();
  }

  Future<void> updateFullProfile(String name, String email, String role) async {
    _userName = name;
    _userEmail = email;
    _userRole = role;
    notifyListeners();

    await _prefs?.setString(_keyName, name);
    await _prefs?.setString(_keyRole, role);
    await _prefs?.setString(_keyEmail, email);
  }

  Future<void> toggleTheme(bool isOn) async {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    await _prefs?.setBool(_keyTheme, isOn);
  }

  /// Selecciona una imagen y la guarda permanentemente en el dispositivo
  Future<void> seleccionarImagen(ImageSource fuente) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: fuente, imageQuality: 80);
      if (pickedFile != null) {
        // Obtenemos un directorio seguro para guardar la imagen permanentemente
        final directory = await getApplicationDocumentsDirectory();
        final String fileName = "profile_${DateTime.now().millisecondsSinceEpoch}.png";
        final File localImage = await File(pickedFile.path).copy('${directory.path}/$fileName');

        _imageFile = localImage;
        notifyListeners();
        await _prefs?.setString(_keyImgPath, localImage.path);
      }
    } catch (e) {
      debugPrint("Error al seleccionar imagen: $e");
    }
  }

  // --- LÓGICA DE TRANSACCIONES ---

  void registrarMovimiento({
    required String titulo,
    required double monto,
    required AccountType cuenta,
    required TransactionType tipo,
    required String categoria,
  }) {
    double saldoDisponible = _obtenerSaldoActual(cuenta);
    bool esSobregiro = (tipo == TransactionType.gasto && monto > saldoDisponible);

    if (tipo == TransactionType.ingreso) {
      _actualizarSaldo(cuenta, monto);
    } else {
      _actualizarSaldo(cuenta, -monto);
    }

    _movimientos.insert(0, {
      'titulo': titulo,
      'monto': monto,
      'tipo': tipo,
      'cuenta': cuenta.name,
      'categoria': categoria,
      'fecha': DateTime.now(),
      'alerta': esSobregiro,
    });
    
    notifyListeners();
  }

  double _obtenerSaldoActual(AccountType cuenta) {
    switch (cuenta) {
      case AccountType.efectivo: return saldoEfectivo;
      case AccountType.banco: return saldoBanco;
      case AccountType.ahorros: return saldoAhorros;
    }
  }

  void _actualizarSaldo(AccountType cuenta, double monto) {
    if (cuenta == AccountType.efectivo) saldoEfectivo += monto;
    else if (cuenta == AccountType.banco) saldoBanco += monto;
    else saldoAhorros += monto;
  }
  
  // --- MÓDULO DE CÁLCULO FINANCIERO ---
  double _interestGenerated = 0.0;
  double _totalAmountCalculated = 0.0;
  double get interestGenerated => _interestGenerated;
  double get totalAmountCalculated => _totalAmountCalculated;

  void processSimpleInterest(double p, double r, double t) {
    _interestGenerated = (p * r * t) / 100;
    _totalAmountCalculated = p + _interestGenerated;
    notifyListeners();
  }

  void processCompoundInterest(double p, double r, double t) {
    // A = P(1 + r/100)^t
    _totalAmountCalculated = p * pow((1 + (r / 100)), t);
    _interestGenerated = _totalAmountCalculated - p;
    notifyListeners();
  }

  // --- ESCENARIOS DE USO ---
  final List<FinancialCase> _casosUso = [
    FinancialCase(id: '1', title: 'Fondo de Emergencia', description: 'Simulación con tasa del 5% anual.', principal: 10000, rate: 5, term: 2),
    FinancialCase(id: '2', title: 'Inversión Largo Plazo', description: 'Poder del interés compuesto (8% anual).', principal: 50000, rate: 8, term: 15, isCompound: true),
  ];
  List<FinancialCase> get casosUso => _casosUso;
}