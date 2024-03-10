import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:neo_finance/constants/entity_interface.dart';
import 'package:neo_finance/models/operation.dart';
import 'package:neo_finance/models/transaction.dart';

import '../database_provider.dart';

class AddTransactionController extends GetxController {

  RxInt _id = (-1).obs;
  int _idx = -1;

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
  List<String> _origoperations = [];
  List<String> _origcontragents = [];
  final Rx<List<String>> _operations = Rx<List<String>>([]);
  final Rx<List<String>> _contragents = Rx<List<String>>([]);
  late ITraEntity traPref;
  @override
  void onInit() {
    super.onInit();
    var arg = Get.arguments;
    if(arg == null){
      throw Exception("AddTransactionController arguments is null");
    }
    var tp = Get.arguments['traPref'];
    if(tp == null){
      throw Exception("AddTransactionController traPref is null");
    }
    traPref = tp;
    updateOperations();
    updateContragents();
    if(Get.arguments['tm'] != null) {
      loadTransaction(Get.arguments['tm'], Get.arguments['idx']);
    } else {
      loadTransaction();
    }
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
    _comment.value = tra.comment ?? '';
  }

  filterOperations(filter) {
    _operations.value = _origoperations.where((element) => element.toLowerCase().contains(filter.toLowerCase())).toList();
  }

  filterContragents(filter) {
    _contragents.value = _origcontragents.where((element) => element.toLowerCase().contains(filter.toLowerCase())).toList();
  }

  updateOperations() async {
    List<Map<String, dynamic>> operations = await traPref.operations.query();
    _origoperations = List.generate(operations.length, (index) {
      return operations[index]['name'];
    });
    _operations.value = _origoperations;
  }

  updateContragents() async {
    List<Map<String, dynamic>> contragetns =
        await DatabaseProvider.queryContragents();
    _origcontragents = List.generate(contragetns.length, (index) {
      return contragetns[index]['name'];
    });
    _contragents.value = _origcontragents;
  }
}
