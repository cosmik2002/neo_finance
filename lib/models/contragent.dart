class ContragentModel {
  int? id;
  final String name;
  int is_from;
  int is_to;

  ContragentModel(
      {this.id,
      required this.name,
      required this.is_from,
      required this.is_to});

  Map<String, dynamic> toMap() {
    return {'name': name, 'is_from': is_from, 'is_to': is_to};
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'is_from': is_from, 'is_to': is_to};
  }

  factory ContragentModel.fromJson(Map<String, dynamic> json) =>
      ContragentModel(
          id: json['id'],
          name: json['name'],
          is_from: json['is_from'],
          is_to: json['is_to']);

  @override
  bool operator == (dynamic other) =>
      other is ContragentModel &&
      other.runtimeType == runtimeType &&
      other.name == name;

  @override
  int get hashCode => name.hashCode;
}
