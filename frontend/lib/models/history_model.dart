class HistoryModel {
  final String id;
  final String userFullName;
  final String userAccountNo;
  final String agentId;
  final String agentName;
  final double amount;
  final double actualZakatAmount;
  final String currency;
  final String paymentMethod;
  final DateTime paidAt;
  final Map<String, dynamic>? waafiResponse;

  HistoryModel({
    required this.id,
    required this.userFullName,
    required this.userAccountNo,
    required this.agentId,
    required this.agentName,
    required this.amount,
    required this.actualZakatAmount,
    required this.currency,
    required this.paymentMethod,
    required this.paidAt,
    this.waafiResponse,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      id: json['_id'] ?? '',
      userFullName: json['userFullName'] ?? '',
      userAccountNo: json['userAccountNo'] ?? '',
      agentId: json['agentId'] ?? '',
      agentName: json['agentName'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      actualZakatAmount: (json['actualZakatAmount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      paidAt: DateTime.parse(json['paidAt']),
      waafiResponse: json['waafiResponse'],
    );
  }
}
