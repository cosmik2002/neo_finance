import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neo_finance/google_sheet_provider.dart';

import '../controllers/add_transaction_controller.dart';
import 'package:get/get.dart';

import '../controllers/theme_controller.dart';
import '../database_provider.dart';
import '../models/transaction.dart';
import '../widgets/input_field.dart';


class AddTransactionScreen2 extends StatelessWidget {
  AddTransactionScreen2({Key? key}) : super(key: key);

  final AddTransactionController _addTransactionController =
  Get.put(AddTransactionController());

  final _themeController = Get.find<ThemeController>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  final List<String> _transactionTypes = ['Income', 'Expense'];

  final DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
          body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(children: [
                Expanded(
                  child: InputField(
                    hint: _addTransactionController.selectedDate.isNotEmpty
                        ? _addTransactionController.selectedDate
                        : DateFormat("dd.MM.yyyy").format(now),
                    label: 'Date',
                    widget: IconButton(
                      onPressed: () => _getDateFromUser(context),
                      icon: Icon(
                        Icons.calendar_month_outlined,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount'),
                ),
                InputField(
                  hint: _addTransactionController.selectedOperation.isNotEmpty
                      ? _addTransactionController.selectedOperation
                      : _addTransactionController.operationsButton[0],
                  label: 'Category',
                  widget: IconButton(
                      onPressed: () => _showDialog(context, true),
                      icon: Icon(
                        Icons.keyboard_arrow_down_sharp,
                      )),
                ),
                Expanded(
                    child: ListView.builder(
                        itemCount: _addTransactionController.operationsButton.length,
                        itemBuilder: (context,index){
                          return ElevatedButton(
                            onPressed: ()=>_addTransaction(_addTransactionController.operationsButton[index]),
                            child: Text(_addTransactionController.operationsButton[index]),
                          );
                        })
                )        ])
          )
      );
    });
  }

  _showDialog(BuildContext context, bool isCategories) {
    Get.defaultDialog(
      title: "Кому",
      content: SizedBox(
        width: MediaQuery.of(context).size.width * .7,
        height: MediaQuery.of(context).size.height * .4,
        child: ListView.builder(
          itemCount: isCategories ? _addTransactionController.operationsButton.length : [].length,
          itemBuilder: (context, i) {
            final data = isCategories ? _addTransactionController.operationsButton[i] : '';
            return ListTile(
              onTap: () {
                isCategories
                    ? _addTransactionController.updateSelectedOperation(data)
                    : _addTransactionController.updateSelectedFrom(data);
                Get.back();
              },
              title: Text(data),
            );
          },
        ),
      ),
    );
  }

  _getDateFromUser(BuildContext context) async {
    DateTime? pickerDate = await showDatePicker(
        context: context,
        firstDate: DateTime(2012),
        initialDate: DateTime.now(),
        lastDate: DateTime(2122));

    if (pickerDate != null) {
      _addTransactionController
          .updateSelectedDate(DateFormat.yMd().format(pickerDate));
    }
  }

   _addTransaction (operation) async {
    final TransactionModel transactionModel = TransactionModel(
      amount: double.parse(_amountController.text),
      date: DateFormat('dd.MM.yyyy').format( DateTime.now()),
        operation: operation,
      from: "НЭО",
      to: "test",
      comment: 'comment',
      //date: _addTransactionController.selectedDate,
    );
    if(await GoogleSheetsIntegration.uploadDataToGoogleSheets(transactionModel)){
      transactionModel.status = '1';
    }
    await DatabaseProvider.insertTransaction(transactionModel);
    Get.back();

  }
}