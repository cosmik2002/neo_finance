import 'package:gsheets/gsheets.dart';
import 'package:neo_finance/models/contragent.dart';
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
  static List<String> operations = [];
  static List<String> teachers = [];
  static var settingsSheetTitle = 'позиции';
  static var operationTypesColumnHeader = 'Тип операции2';
  static var teachersColumnHeader = 'Учителя';
  static var transactionSheetTitle = 'Школа 23/24';

  // static final AddTransactionController _addTransactionController =
  // Get.put(AddTransactionController());


 static Future<Map<String, List<String>>> getDataFromGoogleSheets() async {
    final gsheets = GSheets(Keys.googleKey);
    final spreadsheet = await gsheets.spreadsheet(spreadsheetId);
    var sheet = spreadsheet.worksheetByTitle(settingsSheetTitle);
    if (sheet == null) {
      return {};
    }
    var headers = await sheet.values.row(1);
    try {
      DatabaseProvider.startBatch();

      var operationCol = headers.indexOf(operationTypesColumnHeader);
      if (operationCol != -1) {
        operations = await sheet.values.column(operationCol + 1, fromRow: 2);
        await DatabaseProvider.deleteAllOperations();
        for (var operation in operations) {
          await DatabaseProvider.insertOperation(
              OperationModel(id: null, name: operation, dt: '', kt: ''));
        }
      }
      var tichersCol = headers.indexOf(teachersColumnHeader);
      if (tichersCol != -1) {
        teachers = await sheet.values.column(tichersCol + 1, fromRow: 2);
        await DatabaseProvider.deleteAllTeachers();
        for (var teacher in teachers) {
          await DatabaseProvider.insertTeacher(
              TeacherModel(id: null, name: teacher));
        }
      }

      var sheetTra = spreadsheet.worksheetByTitle(transactionSheetTitle);
      if (sheetTra != null) {
        var transactions = await sheetTra.values.allRows(fromRow: 2);
        var epoch = new DateTime(1899, 12, 30);
        var currentDate;
        var dbContragents = await DatabaseProvider.queryContragents();
        List<ContragentModel> contragents = [];
        List<Map<String, dynamic>> dbTransactions =
            await DatabaseProvider.queryTransactions();

        List<TransactionModel> transactionList =
            List.generate(dbTransactions.length, (index) {
          return TransactionModel().fromJson(dbTransactions[index]);
        });
        List<ContragentModel> contragentList =
            List.generate(dbContragents.length, (index) {
          return ContragentModel().fromJson(dbContragents[index]);
        }, growable: true);
        transactions = transactions.where((transaction) {
          if (transaction.isEmpty || int.tryParse(transaction[0]) == null)
            return false;
          currentDate = epoch.add(Duration(days: int.parse(transaction[0])));
          var ctr = ContragentModel(name: transaction[3]);
          if (!contragentList.contains(ctr)) {
            contragentList.add(ctr);
            contragents.add(ctr);
          }
          return !transactionList.contains(TransactionModel(
              date: DateFormat('dd.MM.yyyy').format(currentDate),
              operation: transaction[1],
              from: transaction[2],
              to: transaction[3],
              amount: double.parse(transaction[4]),
              comment: transaction.length > 5 ? transaction[5] : ''));
        }).toList();
        for (var contragent in contragents) {
          await DatabaseProvider.insertContragent(contragent);
        }
        for (var transaction in transactions) {
          try {
            currentDate = epoch.add(Duration(days: int.parse(transaction[0])));
            await DatabaseProvider.insertTransaction(TransactionModel(
                date: DateFormat('dd.MM.yyyy').format(currentDate),
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
          for (var operation in operations) {
            DatabaseProvider.insertOperation(
                OperationModel(id: null, name: operation, dt: '', kt: ''));
          }
        }
      }

      DatabaseProvider.commitBatch(noResult: true);
    } catch (e) {
      print(e);
      return {};
    }
    return {'operations': operations, 'teachers': teachers};
  }

  static Future<bool> uploadDataToGoogleSheets(TransactionModel transaction) async {
    try {
      final gsheets = GSheets(Keys.googleKey);
      final spreadsheet = await gsheets.spreadsheet(spreadsheetId);
      var sheet = spreadsheet.worksheetByTitle(transactionSheetTitle);
      // create worksheet if it does not exist yet
      sheet ??= await spreadsheet.addWorksheet(transactionSheetTitle);
      var lastRow = (await sheet.values.allRows()).length;

      // var lastCol = await sheet.cells.lastColumn();
      // update cell at 'B2' by inserting string 'new'
      // print(lastRow);
      final DateFormat formatter = DateFormat('dd.MM.yyyy');
      if(await sheet.values.insertRow(lastRow+1, [transaction.date, transaction.operation,transaction.from,transaction.to, transaction.amount, transaction.comment])){
        return true;
        // db.update('table', values)
        // updateTransaction()
        //  transaction.status=1;
      }
    } catch (e) {
      print('Error uploading data: $e');
    }
    return false;
  }
}
