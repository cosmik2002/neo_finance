import 'package:neo_finance/models/contragent.dart';
import 'package:neo_finance/models/lesson.dart';
import 'package:neo_finance/models/operation.dart';
import 'package:neo_finance/models/transaction.dart';

abstract interface class IModel {
  /// It's really a shame that in 2022 you can't do something like this:
  // factory Model.fromJson<T extends Model>(Map<String, dynamic> json) {
  //   return T.fromJson(json);
  // }

  /// Or even declare an abstract factory that must be implemented:
  // factory Model.fromJson(Map<String, dynamic> json);

  // Not DRY, but this works.
  static T fromJson<T extends IModel>(Map<String, dynamic> json) {
    switch (T) {
      case TransactionModel:
      /// Why the heck without `as T`, does Dart complain:
      /// "A value of type 'User' can't be returned from the method 'fromJson' because it has a return type of 'T'."
      /// when clearly `User extends Model` and `T extends Model`?
        return TransactionModel.fromJson(json) as T;
      case LessonModel:
        return LessonModel.fromJson(json) as T;
      case ContragentModel:
        return ContragentModel.fromJson(json) as T;
      default:
        throw UnimplementedError();
    }
  }

  Map<String, dynamic> toMap();
}