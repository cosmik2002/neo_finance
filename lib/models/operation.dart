import '../constants/model_Interface.dart';

class OperationModel implements IModel{
  final int? id;
  final String? name;
  final String? dt;
  final String? kt;
  int type;

  OperationModel({this.id, this.name, this.dt, this.kt, required this.type});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dt': dt,
      'kt': kt,
      'type': type
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dt': dt,
      'kt': kt,
      'type': type
    };
  }

  OperationModel fromJson(Map<String, dynamic> json) => OperationModel(
      id: json['id'],
      name: json['name'],
      dt: json['dt'],
      kt: json['kt'],
      type: json['type']
   );

}