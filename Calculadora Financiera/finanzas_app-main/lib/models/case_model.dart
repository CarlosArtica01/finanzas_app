class FinancialCase {
  final String id;
  final String title;
  final String description;
  final double principal;
  final double rate;
  final int term;
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
}