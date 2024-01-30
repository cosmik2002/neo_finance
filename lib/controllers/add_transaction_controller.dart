import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:neo_finance/models/operation.dart';
import 'package:neo_finance/models/transaction.dart';

import '../database_provider.dart';

class AddTransactionController extends GetxController {

  RxInt _id = (-1).obs;
  int _idx = -1;
  RxBool _isInAsyncCall = false.obs;
  int? _row_number;

/*
  final TextEditingController dateController = TextEditingController();
  final TextEditingController operationController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();
*/


  final Rx<String> _selectedDate =
      DateFormat("dd.MM.yyyy").format(DateTime.now()).obs;
  final Rx<String> _selectedOperation = Rx<String>('');
  final Rx<String> _selectedFrom = Rx<String>('');
  final Rx<String> _selectedTo = ''.obs;
  final Rx<String> _comment = ''.obs;
  final Rx<double> _amount = 0.0.obs;
  final Rx<List<String>> _operations = Rx<List<String>>([]);
  final Rx<List<String>> _contragents = Rx<List<String>>([]);

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    debugPrint("AddTransactionController INIT");
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    debugPrint("AddTransactionController CLOSE");
  }

  int get id => _id.value;
  int get idx => _idx;
  int get row_number => _row_number ?? -1;
  bool get isInAsyncCall => _isInAsyncCall();

  set isInAsyncCall(bool v) => _isInAsyncCall(v);

  String get selectedDate => _selectedDate.value;

  set selectedDate(String d) => _selectedDate(d);

  String get selectedTo => _selectedTo.value;

  set selectedTo(String v) => _selectedTo(v);

  String get selectedOperation => _selectedOperation.value;

  set selectedOperation(String v) => _selectedOperation(v);

  String get selectedFrom => _selectedFrom.value;

  set selectedFrom(String v) => _selectedFrom(v);

  double get amount => _amount.value;

  set amount(double v) => _amount(v);
  String get comment => _comment.value;
  set comment(String v) => _comment(v);

  List<String> get operations => _operations.value;

  List<String> get contragents => _contragents.value;

  loadTransaction([TransactionModel? tra, int idx = -1]) {
    if (tra == null) {
      _id.value = -1;
      _idx = -1;
      _selectedDate.value = DateFormat("dd.MM.yyyy").format(DateTime.now());
      _selectedOperation.value = '';
      _selectedFrom.value = '';
      _selectedTo.value = '';
      _amount.value = 0;
      return;
    }
    _id.value = tra.id!;
    _idx = idx;
    _selectedDate.value = tra.date;
    _selectedOperation.value = tra.operation!;
    _selectedFrom.value = tra.from ?? '';
    _selectedTo.value = tra.to;
    _amount.value = tra.amount ?? 0;
    _row_number = tra.row_number ?? -1;
  }

  updateOperations() async {
    List<Map<String, dynamic>> operations =
        await DatabaseProvider.queryOperations();
    _operations.value = List.generate(operations.length, (index) {
      return operations[index]['name'];
    });
  }

  updateContragents() async {
    List<Map<String, dynamic>> contragetns =
        await DatabaseProvider.queryContragents();
    _contragents.value = List.generate(contragetns.length, (index) {
      return contragetns[index]['name'];
    });
  }
}
