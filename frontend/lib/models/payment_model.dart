class PaymentModel {
  final String userFullName;
  final String userAccountNo;
  final String agentId;
  final String agentName;
  final double amount;
  final double actualZakatAmount;
  final String currency;

  PaymentModel({
    required this.userFullName,
    required this.userAccountNo,
    required this.agentId,
    required this.agentName,
    required this.amount,
    required this.actualZakatAmount,
    this.currency = 'USD',
  });

  Map<String, dynamic> toJson() {
    return {
      'userFullName': userFullName,
      'userAccountNo': userAccountNo,
      'agentId': agentId,
      'agentName': agentName,
      'amount': amount,
      'actualZakatAmount': actualZakatAmount,
      'currency': currency,
    };
  }
}
