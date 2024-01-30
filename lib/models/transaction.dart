class TransactionModel {
  int? id;
  final String date;
  final double? amount;
  final String? comment;
  final String? operation;
  final String? from;
  final String to;
  String? status;
  int type;
  int? row_number;

  TransactionModel({this.id, required this.date, this.amount,this.operation, this.comment, this.from, this.to = '', this.status, required this.type, this.row_number});
  @override
  bool operator == (
      dynamic other
      )=>
      other is TransactionModel &&
          other.runtimeType == runtimeType &&
          other.date == date && other.operation == operation && other.amount == amount && other.from == from && other.to == to && other.comment == comment;

  @override
  int get hashCode => Object.hash(date, operation, amount, from, to, comment);

    Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'amount': amount,
      'comment': comment,
      'operation': operation,
      'from': from,
      'to': to,
      'status':status,
      'type': type,
      'row_number': row_number
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'amount': amount,
      'comment': comment,
      'operation': operation,
      'from': from,
      'to': to,
      'status':status,
      'type': type,
      'row_number': row_number
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
    id: json['id'],
    amount: json['amount'],
    date: json['date'],
    comment: json['comment'],
    operation: json['operation'],
    from: json['from'],
    to: json['to'],
    status: json['status'],
    type: json['type'],
    row_number: json['row_number']
  );
}
