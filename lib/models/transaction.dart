class TransactionModel {
  final int? id;
  final DateTime? date;
  final double? amount;
  final String? comment;

  TransactionModel({this.id, this.date, this.amount, this.comment});

  Map<String, dynamic> toMap() {
    return {
      'date': date?.toIso8601String(),
      'amount': amount,
      'comment': comment,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date?.toIso8601String(),
      'amount': amount,
      'comment': comment,
    };
  }

  TransactionModel fromJson(Map<String, dynamic> json) => TransactionModel(
    id: json['id'],
    amount: json['amount'],
    date: DateTime.parse(json['date']),
    comment: json['comment'],
  );
}
