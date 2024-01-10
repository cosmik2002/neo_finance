import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:neo_finance/controllers/home_controller.dart';
import 'package:neo_finance/google_sheet_provider.dart';

import '../constants/colors.dart';
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
  final HomeController _homeController = Get.put(HomeController());

  final _themeController = Get.find<ThemeController>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  final DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
          appBar: _appBar(),
          body: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Column(children: [
                InputField(
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
                InputField(
                  hint: '',
                  focus: true,
                  controller: _amountController,
                  label: 'Amount',
                ),
                InputField(
                  hint: _addTransactionController.selectedOperation.isNotEmpty
                      ? _addTransactionController.selectedOperation
                      : _addTransactionController.operationsButton[0],
                  label: 'Category',
                  widget: IconButton(
                      onPressed: () => _showDialog(context, 0),
                      icon: Icon(
                        Icons.keyboard_arrow_down_sharp,
                      )),
                ),
                InputField(
                  hint: _addTransactionController.selectedFrom,
                  label: 'От кого',
                  widget: IconButton(
                      onPressed: () => _showDialog(context, 1),
                      icon: Icon(
                        Icons.keyboard_arrow_down_sharp,
                      )),
                ),
          InputField(
            hint: _addTransactionController.selectedTo,
            label: 'Кому',
            widget: IconButton(
                onPressed: () => _showDialog(context, 2),
                icon: Icon(
                  Icons.keyboard_arrow_down_sharp,
                )),
          ),
                InputField(hint: '', label: 'Комментарий', controller: _commentController,)
          ])),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          onPressed: () => _addTransaction(),
          child: Icon(
            Icons.add,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    });
  }

  _showDialog(BuildContext context, int type) {
    Get.defaultDialog(
      title: "Кому",
      content: SizedBox(
        width: MediaQuery.of(context).size.width * .7,
        height: MediaQuery.of(context).size.height * .4,
        child: ListView.builder(
          itemCount: type==0
              ? _addTransactionController.operationsButton.length
              : _addTransactionController.contragents.length,
          itemBuilder: (context, i) {
            final data = type == 0
                ? _addTransactionController.operationsButton[i]
                : _addTransactionController.contragents[i];
            return ListTile(
              onTap: () {
                type == 0
                    ? _addTransactionController.updateSelectedOperation(data)
                    : (type==1 ? _addTransactionController.updateSelectedFrom(data)
                    : _addTransactionController.updateSelectedTo(data));
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

  _addTransaction() async {
    final TransactionModel transactionModel = TransactionModel(
      amount: double.tryParse(_amountController.text),
      date: _addTransactionController.selectedDate,
      operation: !_addTransactionController.selectedOperation.isEmpty ?
      _addTransactionController.selectedOperation :
      _addTransactionController.operationsButton[0],
      from: _addTransactionController.selectedFrom,
      to: _addTransactionController.selectedTo,
      comment: _commentController.text,
      type: 0
    );
    await DatabaseProvider.insertTransaction(transactionModel);
    var id = await DatabaseProvider.getInsrtedId();
    transactionModel.id = id;
    _homeController.myTransactions.add(transactionModel);
    int idx = _homeController.myTransactions.length-1;
    GoogleSheetsIntegration.addTransactionToGoogleSheets(
        transactionModel).then((value) {
      transactionModel.status = '1';
      _homeController.updateTransaction(idx, transactionModel);
    });
    Get.back();
  }

  _appBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      title: Text(
        'Добавить операцию',
        style: TextStyle(color: _themeController.color),
      ),
      leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: _themeController.color)),
    );
  }
}