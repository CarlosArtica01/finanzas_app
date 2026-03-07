import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CalculosProvider extends ChangeNotifier {
  List<dynamic> _historial = [];
  bool _isLoading = false;
  String? _filtroTipo;
  String? _fechaDesde;
  String? _fechaHasta;

  List<dynamic> get historial => _historial;
  bool get isLoading => _isLoading;
  String? get filtroTipo => _filtroTipo;

  Future<void> cargarHistorial({
    String? tipo,
    String? desde,
    String? hasta,
  }) async {
    _isLoading = true;
    _filtroTipo = tipo;
    _fechaDesde = desde;
    _fechaHasta = hasta;
    notifyListeners();

    final result = await ApiService.getHistorialCalculos(
      tipo: tipo,
      desde: desde,
      hasta: hasta,
    );

    if (result['success']) {
      _historial = result['data'];
    }

    _isLoading = false;
    notifyListeners();
  }

  void setFiltroTipo(String? tipo) {
    _filtroTipo = tipo;
    cargarHistorial(tipo: tipo, desde: _fechaDesde, hasta: _fechaHasta);
  }

  void setRangoFechas(String? desde, String? hasta) {
    _fechaDesde = desde;
    _fechaHasta = hasta;
    cargarHistorial(tipo: _filtroTipo, desde: desde, hasta: hasta);
  }

  void limpiarFiltros() {
    _filtroTipo = null;
    _fechaDesde = null;
    _fechaHasta = null;
    cargarHistorial();
  }
}