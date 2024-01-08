import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:neo_finance/models/operation.dart';

import '../database_provider.dart';

class AddTransactionController extends GetxController {
  final Rx<String> _transactionType = ''.obs;
  final Rx<String> _selectedDate = DateFormat("dd.MM.yyyy").format(DateTime.now()).obs;
  final Rx<String> _selectedOperation = Rx<String>('');
  final Rx<String> _selectedFrom = Rx<String>('');
  final Rx<String> _selectedTo = ''.obs;
  // DateFormat('hh:mm a').format(DateTime.now()).obs;
  final Rx<String> _selectedImage = Rx<String>('');
  final Rx<List<String>> _operationsButtons = Rx<List<String>>([]);
  final Rx<List<String>> _contragents = Rx<List<String>>([]);

  String get selectedDate => _selectedDate.value;
  String get selectedTo => _selectedTo.value;
  String get selectedOperation => _selectedOperation.value;
  String get selectedFrom => _selectedFrom.value;
  String get selectedImage => _selectedImage.value;

  String get transactionType => _transactionType.value;
  List<String> get operationsButton => _operationsButtons.value;
  List<String> get contragents => _contragents.value;

  changeTransactionType(String tt) => _transactionType.value = tt;
  updateSelectedOperation(String category) => _selectedOperation.value = category;
  updateSelectedFrom(String from) => _selectedFrom.value = from;

  updateSelectedDate(String date) => _selectedDate.value = date;
  updateSelectedTo(String to) => _selectedTo.value = to;



  updateOperationsButtons() async {
    List<Map<String, dynamic>> operations =
        await DatabaseProvider.queryOperations();
    _operationsButtons.value = List.generate(operations.length, (index) {
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

  updateSelectedImage(String path) {
    _selectedImage.value = path;

    Get.back();
  }
}
