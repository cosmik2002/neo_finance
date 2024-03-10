import 'package:neo_finance/models/operation.dart';
import 'package:neo_finance/models/transaction.dart';

import '../database_provider.dart';
import 'model_Interface.dart';

class IEntity<T extends IModel>{
  final String _tableName = 'transactions';
  final String _columnHeader = 'Тип операции2';
  get tableName => _tableName;
  get columnHeader => _columnHeader;

  Future<int> insert(T expense) async {
    return DatabaseProvider.insertTable(tableName, expense.toMap());
  }
  Future<int> update(T em, int id) async {
    return DatabaseProvider.updateTable(tableName, em.toMap(),
        where: "id = ?", whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> query() async {
    return DatabaseProvider.queryTable(tableName, orderBy: "(substr(date,7,4) || substr(date,4,2)||substr(date,1,2))");
  }

  Future<int> delete(int id) async {
    return DatabaseProvider.deleteTable(tableName, where: 'id=?', whereArgs: [id]);
  }

   Future<int> deleteAll() async {
    return DatabaseProvider.emptyTable(tableName);
  }
}

class ITraEntity extends IEntity<TransactionModel>{
  final String _transactionSheetTitleRelease = 'Школа 23/24';
  late IEntity<OperationModel> operations;
  get transactionSheetTitle => _transactionSheetTitleRelease;
}

class OperationsPreferences extends IEntity<OperationModel>{
  @override
  final String _tableName = 'operations';
  @override
  final String _columnHeader = 'Тип операции2';

  @override
  Future<List<Map<String, dynamic>>> query() async {
    return DatabaseProvider.queryTable(tableName, orderBy: "name");
  }
}

class Operations2Preferences extends IEntity<OperationModel>{
  @override
  final String _tableName = 'operations2';
  @override
  final String _columnHeader = 'Тип операции';
  @override
  Future<List<Map<String, dynamic>>> query() async {
    return DatabaseProvider.queryTable(tableName, orderBy: "name");
  }
}

class TransactionPreferences extends ITraEntity{
  @override
  final String _tableName = 'transactions';
  @override
  final String _columnHeader = 'Тип операции2';
  @override
  final String _transactionSheetTitleRelease = 'Школа 23/24';
  TransactionPreferences() {
    operations = OperationsPreferences();
  }
}

class TransactionPreferences2 extends ITraEntity{
  @override
  final String _tableName = 'transactions2';
  @override
  final String _columnHeader = 'Тип операции';
  @override
  final String _transactionSheetTitleRelease = 'Школа 23/24 (копия)';
  TransactionPreferences2() {
    operations = Operations2Preferences();
  }
}