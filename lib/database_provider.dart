import 'package:flutter/material.dart';
import 'package:neo_finance/constants/colors.dart';
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
  static const String _dbName = 'expenses.db';

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

  static Future<int> insertTransaction(TransactionModel expense) async {
    return await _db!.insert(_transactionsTableName, expense.toMap());
  }

  static Future<int> insertOperation(OperationModel op) async {
    return await _db!.insert(_operationsTableName, op.toMap());
  }

  static Future<int> insertTeacher(TeacherModel tc) async {
    return await _db!.insert(_teachersTableName, tc.toMap());
  }

  static Future<int> deleteAllTransactions() async {
    return await _db!.delete(_transactionsTableName);
  }

  static Future<int> deleteAllOperations() async {
    return await _db!.delete(_operationsTableName);
  }

  static Future<int> deleteAllTeachers() async {
    return await _db!.delete(_teachersTableName);
  }

  static Future<int> deleteTransaction(String id) async {
    return await _db!.delete(_transactionsTableName, where: 'id=?', whereArgs: [id]);
  }

  static Future<int> updateTransaction(TransactionModel em, int id) async {
    return await _db!.update(_transactionsTableName, em.toMap(), where: "id = ?", whereArgs: [id]);
/*    return await _db!.rawUpdate('''
      UPDATE $_transactionsTableName 
      SET amount = ?,
      date = ?,
      comment = ?,
      WHERE id = ? 
''', [
      em.amount,
      em.date,
      em.comment,
      em.id,
    ]);*/
  }

  static Future<List<Map<String, dynamic>>> queryTransactions() async {
    return await _db!.query(_transactionsTableName);
  }
  static Future<List<Map<String, dynamic>>> queryOperations() async {
    return await _db!.query(_operationsTableName);
  }
}
