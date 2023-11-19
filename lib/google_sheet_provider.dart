import 'package:gsheets/gsheets.dart';
import 'package:neo_finance/models/operation.dart';
import 'package:neo_finance/models/teachers.dart';
import 'package:neo_finance/models/transaction.dart';
import 'package:intl/intl.dart';
// import 'package:sqflite/sqflite.dart' as sqlite;
import 'package:neo_finance/database_provider.dart';
import 'package:neo_finance/keys.dart';
import 'package:sqflite/sqflite.dart';
import 'package:get/get.dart';
import 'controllers/add_transaction_controller.dart';

class GoogleSheetsIntegration {
  static const spreadsheetId = '1Jp8RmkW33WeIXTs9f6R6DFryFacJVHH6mUo6dnQkhME';
  List<String> operations = [];
  List<String> teachers = [];
  //Database db = DatabaseProvider.;
  final AddTransactionController _addTransactionController =
  Get.put(AddTransactionController());

  // GoogleSheetsIntegration(this.db);

  Future<Map<String, List<String>>> getDataFromGoogleSheets() async {
    final gsheets = GSheets(Keys.googleKey);
    final spreadsheet = await gsheets.spreadsheet(spreadsheetId);
    var sheet = spreadsheet.worksheetByTitle('позиции');
    if (sheet == null) {
      return {};
    }
    var headers = await sheet.values.row(1);
    var operationCol = headers.indexOf('Тип операции2');
    if (operationCol != -1) {
      operations = await sheet.values.column(operationCol + 1, fromRow: 2);
      DatabaseProvider.deleteAllOperations();
      for(var operation in operations) {
        DatabaseProvider.insertOperation(OperationModel(id:null, name: operation, dt: '', kt: ''));
      }
    }
    var tichersCol = headers.indexOf('Учителя');
    if (tichersCol != -1) {
      teachers = await sheet.values.column(tichersCol + 1, fromRow: 2);
      DatabaseProvider.deleteAllTeachers();
      for(var teacher in teachers) {
        DatabaseProvider.insertTeacher(TeacherModel(id:null, name: teacher));
      }
    }
    var sheetTra = spreadsheet.worksheetByTitle('Школа 23/24');
    if (sheetTra != null) {
      var transactions = await sheetTra.values.allRows(fromRow: 2);
      var epoch = new DateTime(1899, 12, 30);
      var currentDate;
      List<Map<String, dynamic>> dbTransactions = await DatabaseProvider.queryTransactions();
      List<TransactionModel> transactionList = List.generate(dbTransactions.length, (index) {
        return TransactionModel().fromJson(dbTransactions[index]);});
      transactions = transactions.where((transaction) {
        if (transaction.isEmpty || int.tryParse(transaction[0]) == null)
          return false;
        currentDate =
            epoch.add(Duration(days: int.parse(transaction[0])));
       return !transactionList.contains(TransactionModel(
            date: DateFormat.yMd().format(currentDate),
            operation: transaction[1],
            from: transaction[2],
            to: transaction[3],
            amount: double.parse(transaction[4]),
            comment: transaction.length > 5 ? transaction[5] : ''));
      }).toList();
      for (var transaction in transactions) {
        try {
          currentDate =
          epoch.add(Duration(days: int.parse(transaction[0])));
          DatabaseProvider.insertTransaction(TransactionModel(
              date: DateFormat.yMd().format(currentDate),
              operation: transaction[1],
              from: transaction[2],
              to: transaction[3],
              amount: double.parse(transaction[4]),
              comment: transaction.length > 5 ? transaction[5] : ''));
        } catch (e) {
          print(e);
        }
      }
      // var operationCol = headers.indexOf('Тип операции2');
      if (operationCol != -1) {
        operations = await sheet.values.column(operationCol + 1, fromRow: 2);
        for(var operation in operations) {
          DatabaseProvider.insertOperation(OperationModel(id:null, name: operation, dt: '', kt: ''));
        }
      }
    }

    return {
      'operations' : operations,
      'teachers': teachers
    };
  }

  Future<void> uploadDataToGoogleSheets(TransactionModel transaction) async {
    try {
      final gsheets = GSheets(Keys.googleKey);
      final spreadsheet = await gsheets.spreadsheet(spreadsheetId);
      var sheet = spreadsheet.worksheetByTitle('example');
      // create worksheet if it does not exist yet
      sheet ??= await spreadsheet.addWorksheet('example');
      var lastRow = (await sheet.values.allRows()).length;

      // var lastCol = await sheet.cells.lastColumn();
      // update cell at 'B2' by inserting string 'new'
      print(lastRow);
      final DateFormat formatter = DateFormat('dd.MM.yyyy');
      if(await sheet.values.insertRow(lastRow+1, [transaction.date, transaction.operation,transaction.from,transaction.to, transaction.amount, transaction.comment])){
        // db.update('table', values)
        // updateTransaction()
        //  transaction.status=1;
      }
    } catch (e) {
      print('Error uploading data: $e');
    }
  }
}
