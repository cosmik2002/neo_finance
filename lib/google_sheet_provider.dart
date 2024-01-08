import 'package:flutter/foundation.dart';
import 'package:gsheets/gsheets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl_standalone.dart';
import 'package:neo_finance/models/contragent.dart';
import 'package:neo_finance/models/lesson.dart';
import 'package:neo_finance/models/lesson_name.dart';
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
  static List<String> lessonNames = [];
  static var settingsSheetTitle = 'позиции';
  static var operationTypesColumnHeader = 'Тип операции2';
  static var teachersColumnHeader = 'Учителя';
  static var lessonNamesColumnHeader = 'Предметы';
  static var transactionSheetTitle = 'Школа 23/24';
  static var lessonSheetTitle = 'Учительская';

  // static final AddTransactionController _addTransactionController =
  // Get.put(AddTransactionController());


 static getOperations(sheet, headers) async {
   var operationCol = headers.indexOf(operationTypesColumnHeader);
   if (operationCol != -1) {
     operations = await sheet.values.column(operationCol + 1, fromRow: 2);
     await DatabaseProvider.deleteAllOperations();
     for (var operation in operations) {
       await DatabaseProvider.insertOperation(
           OperationModel(id: null, name: operation, dt: '', kt: ''));
     }
   }
 }

 static getTeachers(sheet, headers) async {
   var tichersCol = headers.indexOf(teachersColumnHeader);
   if (tichersCol != -1) {
     lessonNames = await sheet.values.column(tichersCol + 1, fromRow: 2);
     await DatabaseProvider.deleteAllTeachers();
     for (var teacher in lessonNames) {
       await DatabaseProvider.insertTeacher(
           TeacherModel(id: null, name: teacher));
     }
   }
 }

  static getLessonNames(sheet, headers) async {
    var lesonNamesCol = headers.indexOf(lessonNamesColumnHeader);
    if (lesonNamesCol != -1) {
      lessonNames = await sheet.values.column(lesonNamesCol + 1, fromRow: 2);
      await DatabaseProvider.deleteAllLessonNames();
      for (var name in lessonNames) {
        await DatabaseProvider.insertLessonName(
            LessonNameModel(id: null, name: name));
      }
    }
  }

  static getLessons(spreadsheet) async {
    var sheetTra = spreadsheet.worksheetByTitle(lessonSheetTitle);
    if (sheetTra != null) {
      var lessonsXls = await sheetTra.values.allRows(fromRow: 2);
      var epoch = new DateTime(1899, 12, 30);
      var currentDate;
      List<Map<String, dynamic>> dbLessons =
          await DatabaseProvider.queryLessons();

      List<LessonModel> lessonsList =
      List.generate(dbLessons.length, (index) {
        return LessonModel().fromJson(dbLessons[index]);
      });
      try {
        lessonsXls = lessonsXls.where((lesson) {
          //GoogleSheets keep dates as days integer since 1900
          if (lesson.isEmpty || lesson.length < 5 || int.tryParse(lesson[1]) == null)
            return false;
          currentDate = epoch.add(Duration(days: int.parse(lesson[1])));
          return !lessonsList.contains(LessonModel(
              date: DateFormat('dd.MM.yyyy').format(currentDate),
              type: LessonModel.TYPE_TEACHER,
              teacher: lesson[2],
              name: lesson[3],
              hours: int.tryParse(lesson[4]),
              // student: lesson[3],
              amount: lesson.length > 5 ? double.tryParse(lesson[5]) : null));
          // comment: lesson.length > 5 ? lesson[5] : ''));
        }).toList();
      } catch(e,s) {
        if (kDebugMode) {
          print(e);
          print(s);
        }
        rethrow;
      }
      for (var lesson in lessonsXls) {
        try {
          currentDate = epoch.add(Duration(days: int.parse(lesson[1])));
          await DatabaseProvider.insertLesson(LessonModel(
              date: DateFormat('dd.MM.yyyy').format(currentDate),
              type: LessonModel.TYPE_TEACHER,
              teacher: lesson[2],
              name: lesson[3],
              hours: int.tryParse(lesson[4]),
              // student: lesson[3],
              status: '2',
              amount: lesson.length > 5 ? double.tryParse(lesson[5]) : null));
        } catch (e,s) {
          print(e);
          print(s);
        }
      }
    }
  }

  static Future<(List<TransactionModel>, List<ContragentModel>)> readFromGS(Spreadsheet spreadsheet) async {
    List<TransactionModel> transactionsFromGS = [];
    List<ContragentModel> contragentsFromGS = [];
    var sheetTra = spreadsheet.worksheetByTitle(transactionSheetTitle);
    if (sheetTra != null) {
      var transactionsXls = await sheetTra.values.allRows(fromRow: 2);
      var epoch = DateTime(1899, 12, 30);
      DateTime currentDate;


      for (var transaction in transactionsXls) {
        if (transaction.isEmpty || int.tryParse(transaction[0]) == null) {
          continue;
        }
        currentDate = epoch.add(Duration(days: int.parse(transaction[0])));

        var ctr_to = ContragentModel(name: transaction[3], is_from:0, is_to: 1);
        var ctr_from = ContragentModel(name: transaction[2], is_from:1, is_to: 0);
        var i = contragentsFromGS.indexOf(ctr_to);
        if (i != -1) {
          contragentsFromGS[i].is_to = 1;
        } else {
          contragentsFromGS.add(ctr_to);
        }
        i = contragentsFromGS.indexOf(ctr_from);
        if (i != -1) {
          contragentsFromGS[i].is_from = 1;
        } else {
          contragentsFromGS.add(ctr_from);
        }

        transactionsFromGS.add(TransactionModel(
            date: DateFormat('dd.MM.yyyy').format(currentDate),
            operation: transaction[1],
            from: transaction[2],
            to: transaction[3],
            amount: double.tryParse(transaction[4]),
            comment: transaction.length > 5 ? transaction[5] : ''));
      }
    }
    return (transactionsFromGS, contragentsFromGS);
  }

  static getTransaction(Spreadsheet spreadsheet) async {
    var (transactionsFromGS, contragentsFromGS) = await readFromGS(spreadsheet);
    var dbContragents = await DatabaseProvider.queryContragents();
    List<Map<String, dynamic>> dbTransactions = await DatabaseProvider.queryTransactions();
    List<ContragentModel> contragentsToAdd = [];
    List<ContragentModel> contragentsToUpd = [];
    List<TransactionModel> transactionsToAddList = [];
    List<TransactionModel> transactionsToUpd = [];

    List<TransactionModel> transactionList =
    List.generate(dbTransactions.length, (index) {
      return TransactionModel.fromJson(dbTransactions[index]);
    });

    List<ContragentModel> contragentsExists =
    List.generate(dbContragents.length, (index) {
      return ContragentModel.fromJson(dbContragents[index]);
    }, growable: true);

    transactionsToAddList = transactionsFromGS.where((transaction) {
      return !transactionList.contains(transaction);
    }).toList();

    transactionsToUpd = transactionList.where((transaction) {
      return !transactionsFromGS.contains(transaction);
    }).toList();

    for(var ctr in contragentsFromGS) {
      var idx = contragentsExists.indexOf(ctr);
      if (idx == -1) {
        contragentsExists.add(ctr);
        contragentsToAdd.add(ctr);
      } else {
        if (!contragentsToUpd.contains(ctr) &&
            (contragentsExists[idx].is_from != ctr.is_from ||
                contragentsExists[idx].is_to != ctr.is_to)) {
          ctr.id = contragentsExists[idx].id;
          contragentsToUpd.add(ctr);
        }
      }
    }

    for (var contragent in contragentsToAdd) {
      await DatabaseProvider.insertContragent(contragent);
    }
    for (var contragent in contragentsToUpd) {
      await DatabaseProvider.updateContragent(contragent, contragent.id!);
    }

    for (var transaction in transactionsToAddList) {
      transaction.status = '2';
      await DatabaseProvider.insertTransaction(transaction);
    }

    for (var transaction in transactionsToUpd) {
      transaction.status = null;
      await DatabaseProvider.updateTransaction(transaction, transaction.id!);
    }

  }

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
      await getOperations(sheet, headers);
      await getTeachers(sheet, headers);
      await getTransaction(spreadsheet);
      await getLessonNames(sheet, headers);
      await getLessons(spreadsheet);
      DatabaseProvider.commitBatch(noResult: true);
    } catch (e, s) {
      print(e);
      print(s);
      return {};
    }
    return {'operations': operations, 'teachers': lessonNames};
  }

  static Future<bool> addTransactionToGoogleSheets(TransactionModel transaction) async {
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
      if(await sheet.values.insertRow(lastRow+1, [transaction.date, transaction.operation,transaction.from,transaction.to, transaction.amount, transaction.comment, 'nf'])){
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

  static Future<bool> addLessonToGoogleSheets(LessonModel lesson) async {
    try {
      final gsheets = GSheets(Keys.googleKey);
      final spreadsheet = await gsheets.spreadsheet(spreadsheetId);
      var sheet = spreadsheet.worksheetByTitle(lessonSheetTitle);
      // create worksheet if it does not exist yet
      sheet ??= await spreadsheet.addWorksheet(lessonSheetTitle);
      var lastRow = (await sheet.values.allRows()).length;
      // Intl.systemLocale = await findSystemLocale();
      await initializeDateFormatting('ru', null);
      final DateFormat formatter = DateFormat('MMMM', 'ru');
      print(formatter.format(DateFormat("dd.MM.yyyy").parse(lesson.date!)));
      if(await sheet.values.insertRow(lastRow+1, [formatter.format(DateFormat("dd.MM.yyyy").parse(lesson.date!)), lesson.date, lesson.teacher, lesson.name, lesson.hours, lesson.amount,'', lesson.comment, 'nf'])){
        return true;
      }
    } catch (e) {
      print('Error uploading data: $e');
    }
    return false;
  }
}
