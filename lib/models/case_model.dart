import 'dart:math';

class FinancialCase {
  final String id;
  final String title;
  final String description;
  final double principal;
  final double rate; // Tasa en porcentaje (ej. 12 para 12%)
  final int term;    // Tiempo en años
  final bool isCompound;

  FinancialCase({
    required this.id,
    required this.title,
    required this.description,
    required this.principal,
    required this.rate,
    required this.term,
    this.isCompound = false,
  });

  // Cálculo rápido del monto final (Lógica de negocio encapsulada)
  double get estimatedTotal {
    if (isCompound) {
      // Fórmula: A = P(1 + r/n)^nt -> Simplificado anualmente: A = P(1 + r)^t
      return principal * pow((1 + (rate / 100)), term);
    } else {
      // Fórmula: I = P * r * t -> Total = P + I
      return principal + (principal * (rate / 100) * term);
    }
  }

  // Útil para actualizar solo un campo sin recrear todo el objeto
  FinancialCase copyWith({
    String? title,
    String? description,
    double? principal,
    double? rate,
    int? term,
    bool? isCompound,
  }) {
    return FinancialCase(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      principal: principal ?? this.principal,
      rate: rate ?? this.rate,
      term: term ?? this.term,
      isCompound: isCompound ?? this.isCompound,
    );
  }

  // --- Serialización para persistencia (SQL/NoSQL) ---

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'principal': principal,
      'rate': rate,
      'term': term,
      'isCompound': isCompound,
    };
  }

  factory FinancialCase.fromJson(Map<String, dynamic> json) {
    return FinancialCase(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      principal: (json['principal'] as num).toDouble(),
      rate: (json['rate'] as num).toDouble(),
      term: json['term'] as int,
      isCompound: json['isCompound'] ?? false,
    );
  }
}