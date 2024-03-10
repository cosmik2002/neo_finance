import 'package:get/get.dart';
import 'package:neo_finance/models/lesson.dart';

import '../constants/entity_interface.dart';
import '../database_provider.dart';
import '../google_sheet_provider.dart';
import '../models/transaction.dart';

class HomeController extends GetxController {
  final Rx<List<TransactionModel>> _myTransactions =
      Rx<List<TransactionModel>>([]);
  var traEnt = TransactionPreferences();
  final Rx<List<TransactionModel>> _myTransactions2 =
  Rx<List<TransactionModel>>([]);
  var tra2Ent = TransactionPreferences2();
  final Rx<List<LessonModel>> _lessons = Rx<List<LessonModel>>([]);
  final Rx<int> _tabIndex = 0.obs;
  final RxBool _isInAsyncCall = false.obs;
  Rx<String> errMsg = ''.obs;

  @override
  onInit() async {
    super.onInit();
    GoogleSheetsIntegration.getDataFromGoogleSheets().then((value) async {
      getLessons();
      getTransactions(traEnt);
      getTransactions(tra2Ent);
    }).catchError((err){
      errMsg.value = err.toString();
    });
    getTransactions(traEnt);
    getTransactions(tra2Ent);
    getLessons();
  }

  // List<TransactionModel> get myTransactions => _myTransactions.value;

  Rx<List<TransactionModel>> _getTransactionsList(ITraEntity e){
    if(e is TransactionPreferences) {
      return _myTransactions;
    } else {
      return _myTransactions2;
    }
  }

  List<TransactionModel> getTransactionsListValues(ITraEntity e){
    if(e is TransactionPreferences) {
      return _myTransactions.value;
    } else {
      return _myTransactions2.value;
    }
  }

  _setTransactionsList(ITraEntity e, List<TransactionModel> l){
    if(e is TransactionPreferences) {
      _myTransactions.value = l;
    } else {
      _myTransactions2.value = l;
    }
  }

  List<LessonModel> get lessons => _lessons.value;

  int get tabIndex => _tabIndex.value;

  tabIndexSet(x) => _tabIndex.value = x;

  bool get isInAsyncCall => _isInAsyncCall();

  set isInAsyncCall(bool v) => _isInAsyncCall(v);

  updateTransaction(ITraEntity e, int idx, TransactionModel m) {
    var l = _getTransactionsList(e);
    l.value[idx] = m;
    e.update(m, m.id!);
    l.refresh();
  }

  deleteTransaction(ITraEntity e, int idx) {
    var id = getTransactionsListValues(e)[idx].id;
      if ( id!= null) {
        e.delete(id);
        //DatabaseProvider.deleteTransaction(_myTransactions.value[idx].id!);
      }
    getTransactionsListValues(e).removeAt(idx);
    _getTransactionsList(e).refresh();
  }

  updateLesson(int idx, LessonModel m) {
    _lessons.value[idx] = m;
    DatabaseProvider.updateLesson(m, m.id!);
    _lessons.refresh();
  }

  deleteLesson(int idx) {
    if (_lessons.value[idx].id != null) {
      DatabaseProvider.deleteLesson(_lessons.value[idx].id!);
    }
    _lessons.value.removeAt(idx);
    _lessons.refresh();
  }

  getTransactions(ITraEntity e) async {
    List<Map<String, dynamic>> transactions =
        await e.query();
    var l = _getTransactionsList(e);
    _setTransactionsList(e, List.generate(transactions.length, (index) {
      return TransactionModel.fromJson(transactions[index]);
    }));
  }

  getLessons() async {
    List<Map<String, dynamic>> lessonsLc =
        await DatabaseProvider.queryLessons();
    _lessons.value = List.generate(lessonsLc.length, (index) {
      return LessonModel.fromJson(lessonsLc[index]);
    });
  }

  clearBase() async {
    // await DatabaseProvider.deleteAllTransactions();
    traEnt.deleteAll();
    await DatabaseProvider.deleteAllLessons();
    getTransactions(traEnt);
    getTransactions(tra2Ent);
    getLessons();

    // await DatabaseProvider.deleteAllContragents();
  }

  updateBase() async {
    await GoogleSheetsIntegration.getDataFromGoogleSheets();
    getTransactions(traEnt);
    getTransactions(tra2Ent);
    getLessons();
  }
}
