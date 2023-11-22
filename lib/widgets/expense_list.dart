import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class ExpenseList extends StatelessWidget {
  final _homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Expanded(
        child: ListView.builder(
          itemCount: _homeController.myTransactions.length,
          itemBuilder: (context, i) {
            final transaction = _homeController.myTransactions[i];
            // final bool isIncome = transaction.type == 'Income' ? true : false;
            final text =
                '${transaction.date} ${transaction.operation} ${transaction.from} ${transaction.to} ${transaction.amount}';
            // final formatAmount = '- $text';
            return Text(text);
/*        return transaction.date ==
              DateFormat.yMd().format(_homeController.selectedDate)
              ? GestureDetector(
            onTap: () async {
              await Get.to(() => EditTransactionScreen(tm: transaction));
              _homeController.getTransactions();
            },
            child: TransactionTile(
                transaction: transaction,
                formatAmount: formatAmount,
                isIncome: isIncome),
          )
              : SizedBox();*/
          },
        ),
      );
    });
  }
}
