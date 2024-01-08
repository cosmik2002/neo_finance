class StudentModel {
  final int? id;
  final String? name;

  StudentModel({this.id, this.name});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }

  StudentModel fromJson(Map<String, dynamic> json) => StudentModel(
    id: json['id'],
    name: json['name'],
  );

}