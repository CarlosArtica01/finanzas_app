import 'package:flutter/material.dart';
import 'dart:math';
import '../models/case_model.dart';

enum AccountType { efectivo, banco, ahorros }
enum TransactionType { ingreso, gasto }

class FinanceController extends ChangeNotifier {

  String _userName = "Usuario SYAC";
  String get userName => _userName;

  void updateUserName(String newName) {
    _userName = newName;
    notifyListeners();
  }
  // --- PARTE 1: CÁLCULOS DE INTERÉS ---
  double _interestGenerated = 0.0;
  double _totalAmountCalculated = 0.0;

  double get interestGenerated => _interestGenerated;
  double get totalAmountCalculated => _totalAmountCalculated;

  // --- PARTE 2: PRESUPUESTO Y CUENTAS ---
  double saldoEfectivo = 0.0;
  double saldoBanco = 0.0;
  double saldoAhorros = 0.0;

  final List<Map<String, dynamic>> _movimientos = [];
  List<Map<String, dynamic>> get movimientos => _movimientos;

  double get saldoTotalGeneral => saldoEfectivo + saldoBanco + saldoAhorros;

  // --- PARTE 3: CASOS DE USO ---
  final List<FinancialCase> _casosUso = [
    FinancialCase(
      id: '1',
      title: 'Ahorro para Emergencias',
      description: 'Calcula cuánto tendrías en 2 años con una tasa base del 5%.',
      principal: 10000,
      rate: 5,
      term: 2,
    ),
    FinancialCase(
      id: '2',
      title: 'Plan de Jubilación Temprana',
      description: 'Simulación de interés compuesto a 20 años.',
      principal: 50000,
      rate: 8,
      term: 20,
      isCompound: true,
    ),
  ];

  List<FinancialCase> get casosUso => _casosUso;

  // --- MÉTODOS DE LÓGICA ---

  void processSimpleInterest(double p, double r, double t) {
    _interestGenerated = (p * r * t) / 100;
    _totalAmountCalculated = p + _interestGenerated;
    notifyListeners();
  }

  void processCompoundInterest(double p, double r, double t) {
    _totalAmountCalculated = p * pow((1 + (r / 100)), t);
    _interestGenerated = _totalAmountCalculated - p;
    notifyListeners();
  }

  /// Registra un movimiento y permite saldos negativos si es un gasto mayor al disponible.
  void registrarMovimiento({
    required String titulo,
    required double monto,
    required AccountType cuenta,
    required TransactionType tipo,
    required String categoria,
  }) {
    bool esSobregiro = false;

    if (tipo == TransactionType.ingreso) {
      // Lógica de Ingresos
      if (cuenta == AccountType.efectivo) saldoEfectivo += monto;
      if (cuenta == AccountType.banco) saldoBanco += monto;
      if (cuenta == AccountType.ahorros) saldoAhorros += monto;
    } else {
      // Lógica de Gastos con detección de sobregiro
      double saldoTemporal = 0;
      
      if (cuenta == AccountType.efectivo) {
        saldoTemporal = saldoEfectivo;
        saldoEfectivo -= monto;
      } else if (cuenta == AccountType.banco) {
        saldoTemporal = saldoBanco;
        saldoBanco -= monto;
      } else if (cuenta == AccountType.ahorros) {
        saldoTemporal = saldoAhorros;
        saldoAhorros -= monto;
      }

      // Si el monto del gasto es mayor a lo que había antes de restar
      if (monto > saldoTemporal) {
        esSobregiro = true;
      }
    }

    // Insertar en el historial incluyendo la bandera de alerta
    _movimientos.insert(0, {
      'titulo': titulo,
      'monto': monto,
      'tipo': tipo,
      'cuenta': cuenta.toString().split('.').last,
      'categoria': categoria,
      'fecha': DateTime.now(),
      'alerta': esSobregiro, // Nuevo: Indica si se gastó más de lo disponible
    });

    notifyListeners();
  }

  void agregarCaso(FinancialCase nuevoCaso) {
    _casosUso.insert(0, nuevoCaso);
    notifyListeners();
  }
}