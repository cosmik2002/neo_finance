import 'package:flutter/material.dart';

import '../controllers/add_transaction_controller.dart';
import 'package:get/get.dart';

import '../controllers/theme_controller.dart';


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
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount'),
                ),
                Expanded(
                    child: ListView.builder(
                        itemCount: _addTransactionController.operationsButton.length,
                        itemBuilder: (context,index){
                          return ElevatedButton(
                            onPressed: ()=>'',
                            child: Text(_addTransactionController.operationsButton[index]),
                          );
                        })
                )        ])
          )
      );
    });
  }
}