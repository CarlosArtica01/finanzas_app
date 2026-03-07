import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MetaProvider extends ChangeNotifier {
  double _montoObjetivo = 100000;
  double _montoActual = 0;
  double _porcentajeAvance = 0;
  bool _isLoading = false;

  double get montoObjetivo => _montoObjetivo;
  double get montoActual => _montoActual;
  double get porcentajeAvance => _porcentajeAvance;
  bool get isLoading => _isLoading;

  MetaProvider() {
    cargarMeta();
  }

  Future<void> cargarMeta() async {
    _isLoading = true;
    notifyListeners();

    final result = await ApiService.getMetaJubilacion();
    if (result['success'] && result['data'] != null) {
      _montoObjetivo = double.parse(result['data']['monto_objetivo'].toString());
      _montoActual = double.parse(result['data']['monto_actual'].toString());
      _porcentajeAvance = double.parse(result['data']['porcentaje_avance'].toString());
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> actualizarMontoActual(double nuevoMonto) async {
    _montoActual = nuevoMonto;
    _isLoading = true;
    notifyListeners();

    final result = await ApiService.updateMetaJubilacion(nuevoMonto);
    if (result['success']) {
      _porcentajeAvance = double.parse(result['data']['porcentaje_avance'].toString());
    }

    _isLoading = false;
    notifyListeners();
  }

  double get progreso {
    if (_montoObjetivo == 0) return 0;
    return (_montoActual / _montoObjetivo).clamp(0.0, 1.0);
  }

  String get progresoTexto {
    return '${(progreso * 100).toStringAsFixed(1)}%';
  }
}