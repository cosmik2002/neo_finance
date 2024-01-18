class LessonModel {
  int? id;
  final String? date;
  final double? amount;
  final String? comment;
  final String? name;
  final String? teacher;
  final String? student;
  final int? hours;
  int? row_number;
  String? type;
  String? status;
  static const TYPE_TEACHER = '1';
  static const TYPE_STUDENT = '2';

  LessonModel({this.id, this.date, this.amount,this.name, this.comment, this.teacher, this.student, this.hours, this.type, this.status, this.row_number});
  @override
  bool operator == (
      dynamic other
      )=>
      other is LessonModel &&
          other.runtimeType == runtimeType
          && other.date == date
          && other.hours == hours
          && other.type == type
          && (type == TYPE_TEACHER ? other.teacher == teacher : other.student == student) && other.comment == comment;

  @override
  int get hashCode => Object.hash(date, type, hours, teacher, student, comment);

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'amount': amount,
      'comment': comment,
      'name': name,
      'teacher': teacher,
      'student': student,
      'hours': hours,
      'type':type,
      'status': status,
      'row_number': row_number
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'amount': amount,
      'comment': comment,
      'name': name,
      'teacher': teacher,
      'student': student,
      'hours': hours,
      'type':type,
      'status': status,
      'row_number': row_number
    };
  }

  factory LessonModel.fromJson(Map<String, dynamic> json) => LessonModel(
      id: json['id'],
      amount: json['amount'],
      date: json['date'],
      comment: json['comment'],
      name: json['name'],
      teacher: json['teacher'],
      student: json['student'],
      hours: json['hours'],
      type: json['type'],
      status: json['status'],
      row_number: json['row_number']
  );
}
