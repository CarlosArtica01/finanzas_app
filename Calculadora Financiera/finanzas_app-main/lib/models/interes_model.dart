import 'dart:math';

class InterestModel {
  // Fórmula Interés Simple: I = P * r * t
  static double calculateSimpleInterest(double p, double r, double t) {
    return p * (r / 100) * t;
  }

  // Fórmula Interés Compuesto (Variable): A = P(1 + r/n)^(nt)
  // Usaremos capitalización anual para fines educativos
  static double calculateCompoundAmount(double p, double r, double t) {
    return p * pow((1 + (r / 100)), t);
  }
}