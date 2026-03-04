import 'dart:math';

/// Motor de cálculos financieros de SYAC.
/// Proporciona métodos estáticos para proyecciones de inversión.
class InterestModel {
  
  // --- INTERÉS SIMPLE ---
  // Fórmula: I = P * r * t
  // Donde P es Principal, r es tasa anual decimal y t es tiempo en años.

  /// Calcula únicamente el interés generado.
  static double calculateSimpleInterest(double p, double r, double t) {
    return p * (r / 100) * t;
  }

  /// Calcula el monto total (Principal + Interés).
  static double calculateSimpleTotal(double p, double r, double t) {
    return p + calculateSimpleInterest(p, r, t);
  }

  // --- INTERÉS COMPUESTO ---
  // Fórmula: A = P(1 + r)^t
  // Basado en capitalización anual (n=1).

  /// Calcula el monto total final acumulado.
  static double calculateCompoundAmount(double p, double r, double t) {
    if (p <= 0) return 0;
    return p * pow((1 + (r / 100)), t);
  }

  /// Calcula únicamente la ganancia por interés compuesto.
  static double calculateCompoundInterestOnly(double p, double r, double t) {
    return calculateCompoundAmount(p, r, t) - p;
  }
}