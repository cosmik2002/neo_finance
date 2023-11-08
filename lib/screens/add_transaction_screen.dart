import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:neo_finance/constants/colors.dart';
import 'package:neo_finance/constants/theme.dart';
import 'package:neo_finance/controllers/add_transaction_controller.dart';
import 'package:neo_finance/controllers/theme_controller.dart';
import 'package:neo_finance/models/transaction.dart';
import 'package:neo_finance/database_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../constants/categories.dart';
import '../widgets/input_field.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddTransactionScreen extends StatelessWidget {
  AddTransactionScreen({Key? key}) : super(key: key);

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
          resizeToAvoidBottomInset: false,
          // appBar: _appBar(),
          body: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Column(
                children: [
                  InputField(
                    hint: 'Enter transaction name',
                    label: 'Transaction Name',
                    controller: _nameController,
                  ),
                  InputField(
                    hint: 'Enter transaction amount',
                    label: 'Transaction Amount',
                    controller: _amountController,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: InputField(
                          hint: DateFormat.yMd().format(_addTransactionController.selectedDate),
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
                      SizedBox(
                        width: 12.w,
                      ),
                      Expanded(
                        child: InputField(
                          hint: _addTransactionController.selectedTime.isNotEmpty
                              ? _addTransactionController.selectedTime
                              : DateFormat('hh:mm a').format(now),
                          label: 'Time',
                          widget: IconButton(
                            onPressed: () => _getTimeFromUser(context),
                            icon: Icon(
                              Icons.access_time_rounded,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  InputField(
                    hint: _addTransactionController.selectedCategory.isNotEmpty
                        ? _addTransactionController.selectedCategory
                        : categories[0],
                    label: 'Category',
                    widget: IconButton(
                        onPressed: () => _showDialog(context, true),
                        icon: Icon(
                          Icons.keyboard_arrow_down_sharp,
                        )),
                  ),
                  InputField(
                    hint: _addTransactionController.selectedMode.isNotEmpty
                        ? _addTransactionController.selectedMode
                        : cashModes[0],
                    isAmount: true,
                    label: 'Mode',
                    widget: IconButton(
                        onPressed: () => _showDialog(context, false),
                        icon: Icon(
                          Icons.keyboard_arrow_down_sharp,
                        )),
                  ),
                ],
              )
          ),
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

  _getTimeFromUser(
      BuildContext context,
      ) async {
    String? formatedTime;
    await showTimePicker(
      initialEntryMode: TimePickerEntryMode.input,
      context: context,
      initialTime: TimeOfDay(
        hour: DateTime.now().hour,
        minute: DateTime.now().minute,
      ),
    ).then((value) => formatedTime = value!.format(context));

    _addTransactionController.updateSelectedTime(formatedTime!);
  }

  _getDateFromUser(BuildContext context) async {
    DateTime? pickerDate = await showDatePicker(
        context: context,
        firstDate: DateTime(2012),
        initialDate: DateTime.now(),
        lastDate: DateTime(2122));

    if (pickerDate != null) {
      _addTransactionController
          .updateSelectedDate(pickerDate);
    }
  }

  _showDialog(BuildContext context, bool isCategories) {
    Get.defaultDialog(
      title: isCategories ? 'Select Category' : 'Select Mode',
      content: SizedBox(
        width: MediaQuery.of(context).size.width * .7,
        height: MediaQuery.of(context).size.height * .4,
        child: ListView.builder(
          itemCount: isCategories ? categories.length : cashModes.length,
          itemBuilder: (context, i) {
            final data = isCategories ? categories[i] : cashModes[i];
            return ListTile(
              onTap: () {
                isCategories
                    ? _addTransactionController.updateSelectedCategory(data)
                    : _addTransactionController.updateSelectedMode(data);
                Get.back();
              },
              title: Text(data),
            );
          },
        ),
      ),
    );
  }

  _addTransaction() async {
    if (_nameController.text.isEmpty || _amountController.text.isEmpty) {
      Get.snackbar(
        'Required',
        'All fields are requried',
        backgroundColor:
        Get.isDarkMode ? Color(0xFF212121) : Colors.grey.shade100,
        colorText: pinkClr,
      );
    } else {
      final TransactionModel transactionModel = TransactionModel(
        // id: DateTime.now().toString(),
        // type: _addTransactionController.transactionType.isNotEmpty
        //     ? _addTransactionController.transactionType
        //     : _transactionTypes[0],
        // image: _addTransactionController.selectedImage,
        // name: _nameController.text,
        amount: double.parse(_amountController.text),
        date: _addTransactionController.selectedDate,
        // time: _addTransactionController.selectedTime.isNotEmpty
        //     ? _addTransactionController.selectedTime
        //     : DateFormat('hh:mm a').format(now),
        // category: _addTransactionController.selectedCategory.isNotEmpty
        //     ? _addTransactionController.selectedCategory
        //     : categories[0],
        // mode: _addTransactionController.selectedMode.isNotEmpty
        //     ? _addTransactionController.selectedMode
        //     : cashModes[0],
      );
      await DatabaseProvider.insertTransaction(transactionModel);
      Get.back();
    }
  }
}