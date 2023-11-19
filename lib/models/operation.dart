class OperationModel {
  final int? id;
  final String? name;
  final String? dt;
  final String? kt;

  OperationModel({this.id, this.name, this.dt, this.kt});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dt': dt,
      'kt': kt,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dt': dt,
      'kt': kt,
    };
  }

  OperationModel fromJson(Map<String, dynamic> json) => OperationModel(
      id: json['id'],
      name: json['name'],
      dt: json['dt'],
      kt: json['kt'],
   );

}