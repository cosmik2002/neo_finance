import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_simple_calculator/flutter_simple_calculator.dart';
import 'package:get_storage/get_storage.dart';
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
      Get.find<AddTransactionController>();
  final HomeController _homeController = Get.find();

  final _themeController = Get.find<ThemeController>();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _operationController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  final DateTime now = DateTime.now();
  @override
  Widget build(BuildContext context) {
    _dateController.text = _addTransactionController.selectedDate;
    _operationController.text = _addTransactionController.selectedOperation;
    _fromController.text = _addTransactionController.selectedFrom;
    _toController.text = _addTransactionController.selectedTo;
    _amountController.text = _addTransactionController.amount.toString();
    _commentController.text = _addTransactionController.comment;
    return Obx(() {
      return Scaffold(
          appBar: _appBar(),
          body: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Column(children: [
                InputField(
                 controller: _dateController,
                  label: 'Дата',
                  widget: IconButton(
                    onPressed: () => _getDateFromUser(context),
                    icon: Icon(
                      Icons.calendar_month_outlined,
                      color: Colors.grey,
                    ),
                  ),
                ),
                InputField(
                  widget:  IconButton(
                      onPressed: () => _showCalculator(context, _amountController.text),
                      icon: Icon(
                        Icons.calculate,
                      )),
                  focus: true,
                  controller: _amountController,
                  label: 'Сумма',
                  onChanged: (data) {
                    //todo разобраться нафига это надо, почему при сохранении не смотреть в контроллеры?
                    //какая-то замута была с диалогом выбора из списка
                    //тут проблема т.к. amount реактивный и сразу перерисовывается, не получается нормально ввести цифры
                    _addTransactionController.amount = double.tryParse(data) ?? 0;
                  },
                ),
                InputField(
                  label: 'Категория',
                  controller: _operationController,
                  widget: IconButton(
                      onPressed: () => _showDialog(context, 0),
                      icon: Icon(
                        Icons.keyboard_arrow_down_sharp,
                      )),
                  onChanged: (data) {
                    _addTransactionController.selectedOperation = data;
                  },
                ),
                InputField(
                  controller: _fromController,
                  label: 'От кого',
                  widget: IconButton(
                      onPressed: () => _showDialog(context, 1),
                      icon: Icon(
                        Icons.keyboard_arrow_down_sharp,
                      )),
                  onChanged: (data) {
                    _addTransactionController.selectedFrom = data;
                  },
                ),
          InputField(
            hint: '',
            controller: _toController,
            label: 'Кому',
            widget: IconButton(
                onPressed: () => _showDialog(context, 2),
                icon: Icon(
                  Icons.keyboard_arrow_down_sharp,
                )),
            onChanged: (data) {
              _addTransactionController.selectedTo = data;
            },
          ),
                InputField(hint: '', label: 'Комментарий', controller: _commentController,
                onChanged: (data){
                  _addTransactionController.comment = data;
                },)
          ])),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          onPressed: () => _addTransaction(),
          child: Icon(
            _addTransactionController.id>=0 ? Icons.edit : Icons.add,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    });
  }

  _showCalculator (BuildContext context, val) {
    Get.defaultDialog(
      content: SizedBox(
        width: MediaQuery.of(context).size.width * .7,
        height: MediaQuery.of(context).size.height * .4,
        child: SimpleCalculator(
          value: double.tryParse(val) ?? 0,
          hideExpression: true,
          onChanged: (key, value, expression) {
            _amountController.text = value.toString();
            _addTransactionController.amount = value ?? 0;
            if (key == "=") {
              Get.back();
            }
          },
        ),
      )
/*
      theme: const CalculatorThemeData(
        displayColor: Colors.black,
        displayStyle: const TextStyle(fontSize: 80, color: Colors.yellow),
      ),
*/
    );
  }

  _showDialog(BuildContext context, int type) {
    Get.defaultDialog(
      title: "Кому",
      content: SizedBox(
        width: MediaQuery.of(context).size.width * .7,
        height: MediaQuery.of(context).size.height * .4,
        child: ListView.builder(
          itemCount: type==0
              ? _addTransactionController.operations.length
              : _addTransactionController.contragents.length,
          itemBuilder: (context, i) {
            final data = type == 0
                ? _addTransactionController.operations[i]
                : _addTransactionController.contragents[i];
            return ListTile(
              onTap: () {
                switch (type) {
                  case 0:
                    _operationController.text = data;
                  _addTransactionController.selectedOperation = data;
                    break;
                  case 1:
                    _fromController.text = data;
                  _addTransactionController.selectedFrom = data;
                    break;
                  case 2:
                    _toController.text = data;
                    _addTransactionController.selectedTo = data;
                    break;
                }
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
          .selectedDate = DateFormat("dd.MM.yyyy").format(pickerDate);
    }
  }

  _addTransaction() async {
    // print(_operationController.text);
    final TransactionModel transactionModel = TransactionModel(
      amount: double.tryParse(_amountController.text) ?? 0,
      date: _addTransactionController.selectedDate,
      operation: _addTransactionController.selectedOperation, //_operationController.text,
      from: _addTransactionController.selectedFrom,
      to: _addTransactionController.selectedTo, //_toController.text,
      comment: _addTransactionController.comment,
      type: 0
    );
    if(_addTransactionController.id >= 0) {
      transactionModel.status = null;
      transactionModel.id = _addTransactionController.id;
      await DatabaseProvider.updateTransaction(transactionModel, _addTransactionController.id);
      GoogleSheetsIntegration.updateTransactionToGoogleSheets(transactionModel, _addTransactionController.row_number).then(
              (value) {
                if(value == 0) {
                  transactionModel.status = '1';
                  _homeController.updateTransaction(_addTransactionController.idx, transactionModel);
                }
              });
    } else {
      await DatabaseProvider.insertTransaction(transactionModel);
      var id = await DatabaseProvider.getInsrtedId();
      transactionModel.id = id;
      _homeController.myTransactions.add(transactionModel);
      int idx = _homeController.myTransactions.length - 1;
      GoogleSheetsIntegration.addTransactionToGoogleSheets(
          transactionModel).then((value) {
            if(value>=0) {
              transactionModel.status = '1';
              transactionModel.row_number = value;
              _homeController.updateTransaction(idx, transactionModel);
            }
      });
    }
    Get.back();
  }

  _appBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      title: Text(
        'Добавить операцию',
        style: TextStyle(color: _themeController.color),
      ),
/*      leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: _themeController.color)),*/
    );
  }
}