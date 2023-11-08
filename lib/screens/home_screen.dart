import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/colors.dart';
import '../controllers/home_controller.dart';
import '../controllers/theme_controller.dart';
import '../widgets/expense_list.dart';
import 'add_transaction_screen.dart';

class HomeScreen extends StatelessWidget{

  final HomeController _homeController = Get.put(HomeController());
  // final _themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            // _themeController.switchTheme();
          },
          icon: Icon(Get.isDarkMode ? Icons.nightlight : Icons.wb_sunny),
          // color: _themeController.color,
        ),
        title: Text('title'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
                '${_homeController.counter}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ExpenseList()
          ],
        ),
      ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          onPressed: () async {
            await Get.to(() => AddTransactionScreen());
            _homeController.getTransactions();
          },
          child: Icon(
            Icons.add,
          ),
        ),
    );
    });
  }
}