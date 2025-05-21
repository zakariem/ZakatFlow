class PaymentModel {
  final String userFullName;
  final String userAccountNo;
  final String agentId;
  final String agentName;
  final double amount;
  final String currency;

  PaymentModel({
    required this.userFullName,
    required this.userAccountNo,
    required this.agentId,
    required this.agentName,
    required this.amount,
    this.currency = 'USD',
  });

  Map<String, dynamic> toJson() {
    return {
      'userFullName': userFullName,
      'userAccountNo': userAccountNo,
      'agentId': agentId,
      'agentName': agentName,
      'amount': amount,
      'currency': currency,
    };
  }
}
