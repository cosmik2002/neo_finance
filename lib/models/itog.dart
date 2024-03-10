import 'package:intl/intl.dart';
import 'package:neo_finance/database_provider.dart';

class ItogDbModel {
  Map<(String, String),Map<String, dynamic>> itog = {};

  (String, String) _getKey( row, [bool isCred=false]){
    String sub;
    String cont;
    if(isCred) {
      sub = row['kt'];
      cont = row['from'];
    } else {
      sub = row['dt'];
      cont = row['to'];
    }
    return (sub, (sub!='20' ? cont: ''));
  }

  _checkKey(key) {
    if (!itog.containsKey(key)) {
      itog[key] = {'key': key, 'beg_ost': 0, 'dt': 0, 'kt': 0, 'itog': 0};
    }
  }

  getItog([DateTime? start]) async {
    var sql = "SELECT * from transactions2 tra2 left join operations2 op2 on tra2.operation = op2.name where tra2.status is not null";
    var db = DatabaseProvider.db;
    if(db == null){
      return;
    }
    var transactions = await db.rawQuery(sql);
    for(var transaction in transactions) {
      var key = _getKey(transaction);
      var keyKt = _getKey(transaction, true);
      _checkKey(key);
      _checkKey(keyKt);
      DateTime traDt = DateFormat("dd.MM.yyyy").parse(
          transaction['date'].toString());
      if (start == null || traDt.isAfter(start)) {
        itog[key]?['dt'] += transaction['amount'];
        itog[key]?['itog'] += transaction['amount'];
        itog[keyKt]?['kt'] += transaction['amount'];
        itog[keyKt]?['itog'] -= transaction['amount'];
      }
      else {
        itog[key]?['beg_ost'] += transaction['amount'];
        itog[key]?['itog'] += transaction['amount'];
        itog[keyKt]?['beg_ost'] -= transaction['amount'];
        itog[keyKt]?['itog'] -= transaction['amount'];
      }
    }
    return itog;
  }

  getDetail((String, String) key) async {
    var sql = "SELECT * from transactions2 tra2 left join operations2 op2 on tra2.operation = op2.name where tra2.status is not null and"
        " (op2.dt=?1 or op2.kt=?1)";
    if (key.$2 != "") {
      sql += ' and (tra2."from" = ?2 or tra2."to" = ?2)';
    }
    var db = DatabaseProvider.db;
    if(db == null){
      return;
    }
    var detail = await db.rawQuery(sql, [key.$1, key.$2]);
    return detail;
  }
}