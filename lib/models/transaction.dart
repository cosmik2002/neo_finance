class TransactionModel {
  final int? id;
  final String? date;
  final double? amount;
  final String? comment;
  final String? operation;
  final String? from;
  final String? to;
  final String? status;

  TransactionModel({this.id, this.date, this.amount,this.operation, this.comment, this.from, this.to, this.status});
  @override
  bool operator == (
      dynamic other
      )=>
      other is TransactionModel &&
          other.runtimeType == runtimeType &&
          other.date == date && other.amount == amount && other.from == from && other.to == to && other.comment == comment;

  @override
  // TODO: implement hashCode
  int get hashCode => Object.hash(date, amount, from, to, comment);

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'amount': amount,
      'comment': comment,
      'operation': operation,
      'from': from,
      'to': to,
      'status':status
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'amount': amount,
      'comment': comment,
      'operation': operation,
      'from': from,
      'to': to,
      'status':status
    };
  }

  TransactionModel fromJson(Map<String, dynamic> json) => TransactionModel(
    id: json['id'],
    amount: json['amount'],
    date: json['date'],
    comment: json['comment'],
    operation: json['operation'],
    from: json['from'],
    to: json['to'],
    status: json['status']
  );


}
