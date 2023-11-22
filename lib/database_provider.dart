import 'package:flutter/material.dart';
import 'package:neo_finance/constants/colors.dart';
import 'package:neo_finance/models/contragent.dart';
import 'package:neo_finance/models/transaction.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

import 'models/operation.dart';
import 'models/teachers.dart';

class DatabaseProvider {
  static Database? _db;
  static const int _version = 1;
  static const String _transactionsTableName = 'transactions';
  static const String _operationsTableName = 'operations';
  static const String _teachersTableName = 'teachers';
  static const String _contragentsTableName = 'contragents';
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
      _db = await openDatabase(path,
          version: _version, onCreate: (db, version) {
          db.execute(
            '''CREATE TABLE $_transactionsTableName(id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, amount REAL, comment TEXT, operation TEXT, "from" TEXT, "to" TEXT, status TEXT);''',
          );
          db.execute(
            '''CREATE TABLE lessons(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, date TEXT, teacher TEXT, student TEXT, status TEXT);''',
          );
          db.execute(
            '''CREATE TABLE teachers(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT);''',
          );
          db.execute(
            '''CREATE TABLE students(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT);''',
          );
          db.execute(
            '''CREATE TABLE lesson_names(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT);''',
          );
          db.execute(
            '''CREATE TABLE contragents(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT);''',
          );
          db.execute(
            '''CREATE TABLE $_operationsTableName(id INTEGER PRIMARY KEY AUTOINCREMENT, name, dt TEXT, kt TEXT);''',
          );
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

  static startBatch() {
   batch = _db?.batch();
  }

  static commitBatch({bool? noResult}) {
    if (batch != null) {
      var res =  batch?.commit(noResult: noResult);
      batch = null;
      return res;
    }
  }

  static Future<List<Map<String, dynamic>>> queryTable(String table) async {
    return await _db!.query(table);
  }

  static Future<int> insertTable(String table, Map<String, dynamic> data) async {
    if(batch != null) {
      batch!.insert(table, data);
      return 0;
    }
    return await _db!.insert(table, data);
  }

  static Future<int> updateTable(String table, Map<String, dynamic> data,{ String? where, List<Object?>? whereArgs}) async {
    if(batch != null) {
      batch!.update(table, data, where: where, whereArgs: whereArgs);
      return 0;
    }
    return await _db!.update(table, data, where: where, whereArgs: whereArgs);
  }

  static Future<int> deleteTable(String table, { String? where, List<Object?>? whereArgs}) async {
    if(batch != null) {
      batch!.delete(table, where: where, whereArgs: whereArgs);
      return 0;
    }
    return await _db!.delete(table, where: where, whereArgs: whereArgs);
  }

  static Future<int> emptyTable(String table) async {
    if(batch != null) {
      batch!.delete(table);
      return 0;
    }
    return await _db!.delete(table);
  }

  static Future<int> insertTransaction(TransactionModel expense) async {
    return insertTable(_transactionsTableName, expense.toMap());
  }

  static Future<int> insertOperation(OperationModel op) async {
    return insertTable(_operationsTableName, op.toMap());
  }

  static Future<int> insertTeacher(TeacherModel tc) async {
    return insertTable(_teachersTableName, tc.toMap());
  }

  static Future<int> insertContragent(ContragentModel tc) async {
    return insertTable(_contragentsTableName, tc.toMap());
  }

  static Future<int> deleteAllTransactions() async {
    return emptyTable(_transactionsTableName);
  }

  static Future<int> deleteAllOperations() async {
    return emptyTable(_operationsTableName);
  }


  static Future<int> deleteAllTeachers() async {
    return emptyTable(_teachersTableName);
  }

  static Future<int> deleteAllContragents() async {
    return emptyTable(_contragentsTableName);
  }

  static Future<int> deleteTransaction(String id) async {
    return deleteTable(_transactionsTableName, where: 'id=?', whereArgs: [id]);
  }

  static Future<int> updateTransaction(TransactionModel em, int id) async {
    return updateTable(_transactionsTableName, em.toMap(), where: "id = ?", whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> queryTransactions() async {
    return queryTable(_transactionsTableName);
  }

  static Future<List<Map<String, dynamic>>> queryContragents() async {
    return queryTable(_contragentsTableName);
  }

  static Future<List<Map<String, dynamic>>> queryOperations() async {
    return queryTable(_operationsTableName);
  }
}
