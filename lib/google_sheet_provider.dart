import 'package:flutter/foundation.dart';
import 'package:gsheets/gsheets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:neo_finance/constants/entity_interface.dart';
import 'package:neo_finance/models/contragent.dart';
import 'package:neo_finance/models/lesson.dart';
import 'package:neo_finance/models/lesson_name.dart';
import 'package:neo_finance/models/operation.dart';
import 'package:neo_finance/models/teachers.dart';
import 'package:neo_finance/models/transaction.dart';
import 'package:intl/intl.dart';

import 'package:neo_finance/database_provider.dart';
import 'package:neo_finance/keys.dart';

class GoogleSheetsIntegration {
  static const spreadsheetId = '1Jp8RmkW33WeIXTs9f6R6DFryFacJVHH6mUo6dnQkhME';
  static List<String> lessonNames = [];
  static var settingsSheetTitle = 'позиции';
  static const operationTypesColumnHeader = 'Тип операции2';
  static var operation2TypesColumnHeader = 'Тип операции';
  static var teachersColumnHeader = 'Учителя';
  static var lessonNamesColumnHeader = 'Предметы';
  static const transactionSheetTitleRelease = 'Школа 23/24';
  static var transaction2SheetTitleRelease = 'Школа 23/24 (копия)';
  static var lessonSheetTitleRelease = 'Учительская';
  static const transactionSheetTitleDebug = 'Школа 23/24 тест';
  static var lessonSheetTitleDebug = 'Учительская тест';
  static const transactionSheetTitle =
      kReleaseMode ? transactionSheetTitleRelease : transactionSheetTitleDebug;
  static var lessonSheetTitle =
      kReleaseMode ? lessonSheetTitleRelease : lessonSheetTitleDebug;

  // var insOpTye = <Future<int> Function (OperationModel)>[];
  static (int?,int?) _getDtKtCols(List<String> headers, int col) {
    int?  dtCol, ktCol;
    if(headers.length <= col+2) {
      return (dtCol, ktCol);
    }
    if(headers[col+1] == 'Д') {
      dtCol = col+1;
    }
    if(headers[col+1] == 'К') {
      ktCol = col+1;
    }
    if(headers[col+2] == 'Д') {
      dtCol = col+2;
    }
    if(headers[col+2] == 'К') {
      ktCol = col+2;
    }
    return (dtCol, ktCol);
  }
  static getOperations(sheet, headers, ITraEntity e) async {
    var operationCol = headers.indexOf(e.operations.columnHeader);
    List<String> operations = [];
    List<String> dt = [];
    List<String> kt = [];
    var  (dtCol, ktCol) = _getDtKtCols(headers, operationCol);
    if (operationCol != -1) {
      operations = await sheet.values.column(operationCol + 1, fromRow: 2);
      if(dtCol!=null && ktCol!=null){
        dt = await sheet.values.column(dtCol + 1, fromRow: 2);
        kt = await sheet.values.column(ktCol + 1, fromRow: 2);
      }
      e.operations.deleteAll();
      for (var i = 0; i< operations.length; i++) {
          await e.operations.insert(OperationModel(id: null,
              name: operations[i].trim(),
              dt: dt.length > i ? dt[i].trim(): '',
              kt: kt.length > i ? kt[i].trim(): '',
              type: 0));
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
            TeacherModel(id: null, name: teacher.trim()));
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
            LessonNameModel(id: null, name: name.trim()));
      }
    }
  }

  static getLessons(spreadsheet) async {
    var lessonsXls = await readLessonsFromGS(
        spreadsheet); //await sheetTra.values.allRows(fromRow: 2);
    List<Map<String, dynamic>> dbLessons =
        await DatabaseProvider.queryLessons();
    List<LessonModel> lessonsToAdd = [];
    List<LessonModel> lessonsToUpd = [];

    List<LessonModel> lessonsList = List.generate(dbLessons.length, (index) {
      return LessonModel.fromJson(dbLessons[index]);
    });

    lessonsToAdd = lessonsXls.where((lesson) {
      return !lessonsList.contains(lesson);
    }).toList();

    lessonsToUpd = lessonsList.where((lesson) {
      return !lessonsXls.contains(lesson);
    }).toList();

    for (var lesson in lessonsToAdd) {
      await DatabaseProvider.insertLesson(lesson);
    }
    for (var lesson in lessonsToUpd) {
      lesson.status = null;
      await DatabaseProvider.updateLesson(lesson, lesson.id!);
    }
  }

  static Future<List<LessonModel>> readLessonsFromGS(
      Spreadsheet spreadsheet, [int fromRow = 2, int? count]) async {
    List<LessonModel> lessonsFromGS = [];
    var sheetLes = spreadsheet.worksheetByTitle(lessonSheetTitle);
    // var fromRow = 2;
    if (sheetLes != null) {
      var lessonsXls = await sheetLes.values.allRows(fromRow: fromRow, count: count ?? -1);
      var epoch = DateTime(1899, 12, 30);
      DateTime currentDate;

      for (var ti = 0; ti < lessonsXls.length; ti++) {
        var lesson = lessonsXls[ti];
        if (lesson.isEmpty ||
            lesson.length < 5 ||
            int.tryParse(lesson[1]) == null) {
          continue;
        }
        currentDate = epoch.add(Duration(days: int.parse(lesson[1])));

        lessonsFromGS.add(LessonModel(
            date: DateFormat('dd.MM.yyyy').format(currentDate),
            name: lesson[3].trim(),
            teacher: lesson[2].trim(),
            // to: lesson[3].trim(),
            hours: int.tryParse(lesson[4]),
            amount: lesson.length > 5 ? double.tryParse(lesson[5]) : 0,
            comment: lesson.length > 6 ? lesson[6].trim() : '',
            status: '2',
            type: LessonModel.TYPE_TEACHER,
            row_number: ti + fromRow));
      }
    }
    return (lessonsFromGS);
  }

  static Future<(List<TransactionModel>, List<ContragentModel>)>
      readTransactionsFromGS(Spreadsheet spreadsheet, {int fromRow = 2, int? count, String sheetName=transactionSheetTitle}) async {
    List<TransactionModel> transactionsFromGS = [];
    List<ContragentModel> contragentsFromGS = [];
    var sheetTra = spreadsheet.worksheetByTitle(sheetName);
    // var fromRow = 2;
    if (sheetTra != null) {
      var transactionsXls = await sheetTra.values.allRows(fromRow: fromRow, count: count ?? -1);
      var epoch = DateTime(1899, 12, 30);
      DateTime currentDate;

      for (var ti = 0; ti < transactionsXls.length; ti++) {
        var transaction = transactionsXls[ti];
        if (transaction.isEmpty || int.tryParse(transaction[0]) == null || transaction.length < 5) {
          continue;
        }
        currentDate = epoch.add(Duration(days: int.parse(transaction[0])));

        var ctr_to = ContragentModel(
            name: transaction[3].trim(), is_from: 0, is_to: 1, type: 0);
        var ctr_from = ContragentModel(
            name: transaction[2].trim(), is_from: 1, is_to: 0, type: 0);
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
            operation: transaction[1].trim(),
            from: transaction[2].trim(),
            to: transaction[3].trim(),
            amount: double.tryParse(transaction[4]),
            comment: transaction.length > 5 ? transaction[5].trim() : '',
            type: 0,
            status: '2',
            row_number: ti + fromRow));
      }
    }
    return (transactionsFromGS, contragentsFromGS);
  }

  static getTransaction(Spreadsheet spreadsheet, ITraEntity e) async {
    var (transactionsFromGS, contragentsFromGS) =
        await readTransactionsFromGS(spreadsheet, sheetName: e.transactionSheetTitle);
    var dbContragents = await DatabaseProvider.queryContragents();
    List<Map<String, dynamic>> dbTransactions =
        await e.query();
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

    for (var ctr in contragentsFromGS) {
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
      await e.insert(transaction);
    }

    for (var transaction in transactionsToUpd) {
      transaction.status = null;
      await e.update(transaction, transaction.id!);
    }
  }

  static getDataFromGoogleSheets() async {
    final gsheets = GSheets(Keys.googleKey);
    final spreadsheet = await gsheets.spreadsheet(spreadsheetId);
    var sheet = spreadsheet.worksheetByTitle(settingsSheetTitle);
    if (sheet == null) {
      return {};
    }
    var headers = await sheet.values.row(1);
    try {
      var traPref = TransactionPreferences();
      var tra2Pref = TransactionPreferences2();
      DatabaseProvider.startBatch();
      await getOperations(sheet, headers, traPref);
      await getOperations(sheet, headers, tra2Pref);
      await getTeachers(sheet, headers);
      await getTransaction(spreadsheet, traPref);
      DatabaseProvider.commitBatch(noResult: true);
      DatabaseProvider.startBatch();
      await getTransaction(spreadsheet, tra2Pref);
      await getLessonNames(sheet, headers);
      await getLessons(spreadsheet);
      DatabaseProvider.commitBatch(noResult: true);
    } catch (e, s) {
      if (kDebugMode) {
        print(e);
        print(s);
      }
      rethrow;
    }
  }

  static Future<int> addTransactionToGoogleSheets(
      TransactionModel transaction, ITraEntity e) async {
    try {
      final gsheets = GSheets(Keys.googleKey);
      final spreadsheet = await gsheets.spreadsheet(spreadsheetId);
      var sheet = spreadsheet.worksheetByTitle(e.transactionSheetTitle);
      // create worksheet if it does not exist yet
      sheet ??= await spreadsheet.addWorksheet(e.transactionSheetTitle);
      var lastRow = (await sheet.values.allRows()).length;

      // var lastCol = await sheet.cells.lastColumn();
      // update cell at 'B2' by inserting string 'new'
      // print(lastRow);
      final DateFormat formatter = DateFormat('dd.MM.yyyy');
      if (await sheet.values.insertRow(lastRow + 1, [
        transaction.date,
        transaction.operation,
        transaction.from,
        transaction.to,
        transaction.amount,
        transaction.comment,
        'nf'
      ])) {
        return lastRow+1;
        // db.update('table', values)
        // updateTransaction()
        //  transaction.status=1;
      }
    } catch (e) {
      print('Error uploading data: $e');
      rethrow;
    }
    return -1;
  }

  static Future<Worksheet?> getSheet(String sheetTitle, [createIfNotExists = true]) async {
    final gsheets = GSheets(Keys.googleKey);
    final spreadsheet = await gsheets.spreadsheet(spreadsheetId);
    var sheet = spreadsheet.worksheetByTitle(lessonSheetTitle);
    if(createIfNotExists && sheet == null) {
      // create worksheet if it does not exist yet
      sheet ??= await spreadsheet.addWorksheet(lessonSheetTitle);
    }
    return sheet;
  }

  static Future<bool> checkTransactionToGoogleSheets(TransactionModel tra, int row_number, ITraEntity e) async {
    final gsheets = GSheets(Keys.googleKey);
    final spreadsheet = await gsheets.spreadsheet(spreadsheetId);
    var (traGS, ctGs) =  await readTransactionsFromGS(spreadsheet,fromRow: row_number, count: 1,sheetName: e.transactionSheetTitle);
    return traGS.length ==1 && traGS[0] == tra;
  }

  static Future<int> updateTransactionToGoogleSheets(TransactionModel tra, row_number, ITraEntity e) async {
    try {
      final gsheets = GSheets(Keys.googleKey);
      final spreadsheet = await gsheets.spreadsheet(spreadsheetId);
      var sheet = spreadsheet.worksheetByTitle(e.transactionSheetTitle);
      // create worksheet if it does not exist yet
      sheet ??= await spreadsheet.addWorksheet(e.transactionSheetTitle);
      await initializeDateFormatting('ru', null);
      final DateFormat formatter = DateFormat('MMMM', 'ru');
      if (await sheet.values.insertRow(row_number, [
        tra.date,
        tra.operation,
        tra.from,
        tra.to,
        tra.amount,
        tra.comment,
        'nf'
      ])) {
        return 0;
      }
    } catch (e) {
      print('Error uploading data: $e');
    }
    return -1;
  }

  static Future<bool> checkLessonToGoogleSheets(LessonModel lesson, int row_number) async {
    final gsheets = GSheets(Keys.googleKey);
    final spreadsheet = await gsheets.spreadsheet(spreadsheetId);
    var lessonGS =  await readLessonsFromGS(spreadsheet, row_number, 1);
  return lessonGS.length ==1 && lessonGS[0] == lesson;
  }

  static Future<int> updateLessonToGoogleSheets(LessonModel lesson, row_number) async {
   try {
    final gsheets = GSheets(Keys.googleKey);
    final spreadsheet = await gsheets.spreadsheet(spreadsheetId);
    var sheet = spreadsheet.worksheetByTitle(lessonSheetTitle);
    // create worksheet if it does not exist yet
    sheet ??= await spreadsheet.addWorksheet(lessonSheetTitle);
    await initializeDateFormatting('ru', null);
    final DateFormat formatter = DateFormat('MMMM', 'ru');
    if (await sheet.values.insertRow(row_number, [
      formatter.format(DateFormat("dd.MM.yyyy").parse(lesson.date!)),
      lesson.date,
      lesson.teacher,
      lesson.name,
      lesson.hours,
      lesson.amount,
      '',
      lesson.comment,
      'nf'
    ])) {
      return 0;
    }
  } catch (e) {
  print('Error uploading data: $e');
  }
  return -1;
  }

  static Future<int> addLessonToGoogleSheets(LessonModel lesson) async {
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
      if (await sheet.values.insertRow(lastRow + 1, [
        formatter.format(DateFormat("dd.MM.yyyy").parse(lesson.date!)),
        lesson.date,
        lesson.teacher,
        lesson.name,
        lesson.hours,
        lesson.amount,
        '',
        lesson.comment,
        'nf'
      ])) {
        return lastRow+1;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading data: $e');
      }
      rethrow;
    }
    return -1;
  }
}
