import 'package:flutter/material.dart';
import 'package:neo_finance/constants/colors.dart';
import 'package:neo_finance/models/contragent.dart';
import 'package:neo_finance/models/lesson.dart';
import 'package:neo_finance/models/lesson_name.dart';
import 'package:neo_finance/models/student.dart';
import 'package:neo_finance/models/transaction.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

import 'models/operation.dart';
import 'models/teachers.dart';

class DatabaseProvider {
  static Database? _db;
  static const int _version = 4;
  static const String _transactionsTableName = 'transactions';
  static const String _lessonsTableName = 'lessons';
  static const String _lessonNamesTableName = 'lesson_names';
  static const String _operationsTableName = 'operations';
  static const String _teachersTableName = 'teachers';
  static const String _contragentsTableName = 'contragents';
  static const String _studentsTableName = 'students';
  static const String _dbName = 'expenses.db';
  static Batch? batch;

  static Future<void> initDb() async {
    if (_db != null) {
      return;
    }
    try {
      String path = await getDatabasesPath() + _dbName;
/*      var file = File(path);
      if (await file.exists()) {
        await file.delete();
    }*/
      _db = await openDatabase(path, version: _version,
          onCreate: (db, newVersion) async {
        for (int version = 0; version < newVersion; version++) {
          await _performDbOperationsVersionWise(db, version + 1);
        }
      }, onUpgrade: (db, oldVersion, newVersion) async {
        for (int version = oldVersion; version < newVersion; version++) {
          await _performDbOperationsVersionWise(db, version + 1);
        }
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error initializing database',
        backgroundColor: const Color(0xFF212121),
        colorText: pinkClr,
      );
    }
  }

  static _performDbOperationsVersionWise(Database db, int version) async {
    switch (version) {
      case 1:
        await _databaseVersion1(db);
        break;
      case 2:
        await _databaseVersion2(db);
        break;

      case 3:
        await _databaseVersion3(db);
        break;
      case 4:
        await _databaseVersion4(db);
        break;
/*      case 5:
        await _databaseVersion5(db);
        break;
*/
    }
  }
  static _databaseVersion4(Database db) {
    var sql = "ALTER TABLE $_contragentsTableName ADD COLUMN type int not null default 0";
    db.execute(sql);
    sql = "ALTER TABLE $_operationsTableName ADD COLUMN type int not null default 0";
    db.execute(sql);
    sql = "ALTER TABLE $_transactionsTableName ADD COLUMN type int not null default 0";
    db.execute(sql);

  }

  static _databaseVersion3(Database db) {
    var sql = "ALTER TABLE $_contragentsTableName ADD COLUMN is_from int not null default 0";
    db.execute(sql);
    sql = "ALTER TABLE $_contragentsTableName ADD COLUMN is_to int not null default 0";
    db.execute(sql);
  }

  static _databaseVersion2(Database db) {
    const sql = "ALTER TABLE $_lessonsTableName ADD COLUMN hours int";
    db.execute(sql);
  }

  static _databaseVersion1(Database db) {
    db.execute(
      '''CREATE TABLE $_transactionsTableName(id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, amount REAL, comment TEXT, operation TEXT, "from" TEXT, "to" TEXT, status TEXT);''',
    );
    db.execute(
      '''CREATE TABLE $_lessonsTableName (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, date TEXT, teacher TEXT, student TEXT, type TEXT, comment text, amount REAL, status text);''',
    );
    db.execute(
      '''CREATE TABLE $_teachersTableName (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT);''',
    );
    db.execute(
      '''CREATE TABLE $_studentsTableName (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT);''',
    );
    db.execute(
      '''CREATE TABLE $_lessonNamesTableName (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT);''',
    );
    db.execute(
      '''CREATE TABLE $_contragentsTableName (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT);''',
    );
    db.execute(
      '''CREATE TABLE $_operationsTableName(id INTEGER PRIMARY KEY AUTOINCREMENT, name, dt TEXT, kt TEXT);''',
    );
  }

  static startBatch() {
    batch = _db?.batch();
  }

  static commitBatch({bool? noResult}) {
    if (batch != null) {
      var res = batch?.commit(noResult: noResult);
      batch = null;
      return res;
    }
  }

  static Future<List<Map<String, dynamic>>> queryTable(String table, {String orderBy = ''}) async {

    return await _db!.query(table, orderBy: orderBy != '' ? orderBy : 'id desc');
  }

  Map<Symbol, dynamic> symbolizeKeys(Map<String, dynamic> map){
    return map.map((k, v) => MapEntry(Symbol(k), v));
  }

  static Future<int> insertTable(
      String table, Map<String, dynamic> data) async {
    if (batch != null) {
      batch!.insert(table, data);
      return 0;
    }
    return await _db!.insert(table, data);
  }

  static Future<int?> getInsrtedId() async {
    return Sqflite
        .firstIntValue(await _db!.rawQuery('SELECT last_insert_rowid()'));
  }

  static Future<int> updateTable(String table, Map<String, dynamic> data,
      {String? where, List<Object?>? whereArgs}) async {
    if (batch != null) {
      batch!.update(table, data, where: where, whereArgs: whereArgs);
      return 0;
    }
    return await _db!.update(table, data, where: where, whereArgs: whereArgs);
  }

  static Future<int> deleteTable(String table,
      {String? where, List<Object?>? whereArgs}) async {
    if (batch != null) {
      batch!.delete(table, where: where, whereArgs: whereArgs);
      return 0;
    }
    return await _db!.delete(table, where: where, whereArgs: whereArgs);
  }

  static Future<int> emptyTable(String table) async {
    if (batch != null) {
      batch!.delete(table);
      return 0;
    }
    return await _db!.delete(table);
  }

  static Future<int> insertTransaction(TransactionModel expense) async {
    return insertTable(_transactionsTableName, expense.toMap());
  }

  static Future<int> insertLesson(LessonModel lesson) async {
    return insertTable(_lessonsTableName, lesson.toMap());
  }

  static Future<int> insertLessonName(LessonNameModel lesson_name) async {
    return insertTable(_lessonNamesTableName, lesson_name.toMap());
  }

  static Future<int> insertOperation(OperationModel op) async {
    return insertTable(_operationsTableName, op.toMap());
  }

  static Future<int> insertTeacher(TeacherModel tc) async {
    return insertTable(_teachersTableName, tc.toMap());
  }

  static Future<int> insertStudent(StudentModel tc) async {
    return insertTable(_studentsTableName, tc.toMap());
  }

  static Future<int> insertContragent(ContragentModel tc) async {
    return insertTable(_contragentsTableName, tc.toMap());
  }

  static Future<int> deleteAllTransactions() async {
    return emptyTable(_transactionsTableName);
  }

  static Future<int> deleteAllLessons() async {
    return emptyTable(_lessonsTableName);
  }

  static Future<int> deleteAllLessonNames() async {
    return emptyTable(_lessonNamesTableName);
  }

  static Future<int> deleteAllOperations() async {
    return emptyTable(_operationsTableName);
  }

  static Future<int> deleteAllTeachers() async {
    return emptyTable(_teachersTableName);
  }

  static Future<int> deleteAllStudents() async {
    return emptyTable(_studentsTableName);
  }

  static Future<int> deleteAllContragents() async {
    return emptyTable(_contragentsTableName);
  }

  static Future<int> deleteTransaction(int id) async {
    return deleteTable(_transactionsTableName, where: 'id=?', whereArgs: [id]);
  }

  static Future<int> deleteLesson(int id) async {
    return deleteTable(_lessonsTableName, where: 'id=?', whereArgs: [id]);
  }

  static Future<int> updateTransaction(TransactionModel em, int id) async {
    return updateTable(_transactionsTableName, em.toMap(),
        where: "id = ?", whereArgs: [id]);
  }

  static Future<int> updateLesson(LessonModel em, int id) async {
    return updateTable(_lessonsTableName, em.toMap(),
        where: "id = ?", whereArgs: [id]);
  }

  static Future<int> updateContragent(ContragentModel em, int id) async {
    return updateTable(_contragentsTableName, em.toMap(),
        where: "id = ?", whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> queryTransactions() async {
    return queryTable(_transactionsTableName, orderBy: "(substr(date,7,4) || substr(date,4,2)||substr(date,1,2))");
  }

  static Future<List<Map<String, dynamic>>> queryLessons() async {
    return queryTable(_lessonsTableName, orderBy: "(substr(date,7,4) || substr(date,4,2)||substr(date,1,2))");
  }

  static Future<List<Map<String, dynamic>>> queryLessonNames() async {
    return queryTable(_lessonNamesTableName);
  }

  static Future<List<Map<String, dynamic>>> queryTeachers() async {
    return queryTable(_teachersTableName);
  }

  static Future<List<Map<String, dynamic>>> queryStudents() async {
    return queryTable(_studentsTableName);
  }

  static Future<List<Map<String, dynamic>>> queryContragents() async {
    return queryTable(_contragentsTableName);
  }

  static Future<List<Map<String, dynamic>>> queryOperations() async {
    return queryTable(_operationsTableName);
  }
}
