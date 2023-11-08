import 'package:flutter/material.dart';
import 'package:neo_finance/constants/colors.dart';
import 'package:neo_finance/models/transaction.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  static Database? _db;
  static const int _version = 1;
  static const String _transactionsTableName = 'transactions';
  static const String _dbName = 'expenses.db';

  static Future<void> initDb() async {
    if (_db != null) {
      return;
    }
    try {
      String path = await getDatabasesPath() + _dbName;
      _db = await openDatabase(path,
          version: _version, onCreate: (db, version) {
          db.execute(
            '''CREATE TABLE $_transactionsTableName(id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, amount REAL, comment TEXT);''',
          );
          db.execute(
            '''CREATE TABLE teachers(id INTEGER PRIMARY KEY AUTOINCREMENT, name);''',
          );
          db.execute(
            '''CREATE TABLE operations(id INTEGER PRIMARY KEY AUTOINCREMENT, name);''',
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

  static Future<int> deleteTransaction(String id) async {
    return await _db!.delete(_transactionsTableName, where: 'id=?', whereArgs: [id]);
  }

  static Future<int> updateTransaction(TransactionModel em) async {
    return await _db!.rawUpdate('''
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
    ]);
  }

  static Future<List<Map<String, dynamic>>> queryTransactions() async {
    return await _db!.query(_transactionsTableName);
  }
}
