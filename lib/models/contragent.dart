class ContragentModel {
  final int? id;
  final String? name;

  ContragentModel({this.id, this.name});

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

  ContragentModel fromJson(Map<String, dynamic> json) => ContragentModel(
      id: json['id'],
      name: json['name'],
   );

  @override
  bool operator == (
      dynamic other
      )=>
      other is ContragentModel &&
          other.runtimeType == runtimeType &&
          other.name == name;

  @override
  int get hashCode => name.hashCode;
}