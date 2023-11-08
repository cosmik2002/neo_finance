import 'package:get/get.dart';

import '../database_provider.dart';
import '../models/transaction.dart';

class HomeController extends GetxController {
  final Rx<double> _counter = 0.0.obs;

  final Rx<List<TransactionModel>> _myTransactions =
  Rx<List<TransactionModel>>([]);

  double get counter => _counter.value;
  List<TransactionModel> get myTransactions => _myTransactions.value;

  @override
  onInit() {
    super.onInit();
    getTransactions();
  }
  incCounter() {
    _counter.value++;
  }

  getTransactions() async {
    final List<TransactionModel> transactionsFromDB = [];
    List<Map<String, dynamic>> transactions =
    await DatabaseProvider.queryTransactions();
    transactionsFromDB.assignAll(transactions.reversed
        .map((data) => TransactionModel().fromJson(data))
        .toList());
    _myTransactions.value = transactionsFromDB;
    // getTotalAmountForPickedDate(transactionsFromDB);
    // tracker(transactionsFromDB);
  }
}