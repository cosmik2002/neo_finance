class LessonNameModel {
  final int? id;
  final String? name;

  LessonNameModel({this.id, this.name});

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

  LessonNameModel fromJson(Map<String, dynamic> json) => LessonNameModel(
    id: json['id'],
    name: json['name'],
  );

}