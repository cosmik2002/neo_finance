class TeacherModel {
  final int? id;
  final String? name;

  TeacherModel({this.id, this.name});

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

  TeacherModel fromJson(Map<String, dynamic> json) => TeacherModel(
      id: json['id'],
      name: json['name'],
   );

}