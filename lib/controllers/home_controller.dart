import 'package:get/get.dart';
import 'package:neo_finance/models/lesson.dart';

import '../database_provider.dart';
import '../google_sheet_provider.dart';
import '../models/transaction.dart';

class HomeController extends GetxController {

  final Rx<List<TransactionModel>> _myTransactions = Rx<List<TransactionModel>>([]);
  final Rx<List<LessonModel>> _lessons = Rx<List<LessonModel>>([]);
  final Rx<int> _tabIndex=0.obs;
  List<TransactionModel> get myTransactions => _myTransactions.value;
  List<LessonModel> get lessons => _lessons.value;
  int get tabIndex => _tabIndex.value;
  tabIndexSet(x) => _tabIndex.value = x;
  @override
  onInit() async {
    super.onInit();
    GoogleSheetsIntegration.getDataFromGoogleSheets().then((value) {
      getTransactions();
      getLessons();
    });
    getTransactions();
    getLessons();
  }

  updateTransaction(int idx, TransactionModel m) {
    _myTransactions.value[idx] = m;
    DatabaseProvider.updateTransaction(m, m.id!);
    _myTransactions.refresh();
  }

  deleteTransaction(int idx) {
    if(_myTransactions.value[idx].id != null) {
      DatabaseProvider.deleteTransaction(_myTransactions.value[idx].id!);
    }
    _myTransactions.value.removeAt(idx);
    _myTransactions.refresh();
  }

  getTransactions() async {
    List<Map<String, dynamic>> transactions =
    await DatabaseProvider.queryTransactions();
    _myTransactions.value = List.generate(transactions.length, (index) {
      return TransactionModel.fromJson(transactions[index]);
    });
  }

  getLessons() async {
    List<Map<String, dynamic>> lessonsLc =
    await DatabaseProvider.queryLessons();
    _lessons.value = List.generate(lessonsLc.length, (index) {
      return LessonModel().fromJson(lessonsLc[index]);
    });
  }

  clearBase() async {
    await DatabaseProvider.deleteAllTransactions();
    await DatabaseProvider.deleteAllLessons();
    getTransactions();
    getLessons();

    // await DatabaseProvider.deleteAllContragents();
  }

  updateBase() async {
    await GoogleSheetsIntegration.getDataFromGoogleSheets();
    getTransactions();
    getLessons();
  }
}