import 'package:get/get.dart';

import '../database_provider.dart';
import '../google_sheet_provider.dart';
import '../models/transaction.dart';

class HomeController extends GetxController {
  final Rx<double> _counter = 0.0.obs;

  final Rx<List<TransactionModel>> _myTransactions =
  Rx<List<TransactionModel>>([]);

  double get counter => _counter.value;
  List<TransactionModel> get myTransactions => _myTransactions.value;

  @override
  onInit() async {
    super.onInit();
    await GoogleSheetsIntegration().getDataFromGoogleSheets();
    getTransactions();
  }
  incCounter() {
    _counter.value++;
  }

  getTransactions() async {
    final List<TransactionModel> transactionsFromDB = [];
    List<Map<String, dynamic>> transactions =
    await DatabaseProvider.queryTransactions();
    // transactionsFromDB.assignAll(transactions.reversed
    //     .map((data) => TransactionModel().fromJson(data))
    //     .toList());
    _myTransactions.value = List.generate(transactions.length, (index) {
      return TransactionModel().fromJson(transactions[index]);
    });
    // _myTransactions.value = transactionsFromDB;
    incCounter();
    // getTotalAmountForPickedDate(transactionsFromDB);
    // tracker(transactionsFromDB);
  }
}