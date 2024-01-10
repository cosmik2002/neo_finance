import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:neo_finance/database_provider.dart';
import 'package:neo_finance/models/transaction.dart';

import '../controllers/home_controller.dart';
import '../google_sheet_provider.dart';

class ExpenseList extends StatelessWidget {
  final _homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ListView.separated(
        itemCount: _homeController.myTransactions.length,
        // reverse: true,
        separatorBuilder: (c, i) => const Divider(height: 0),
        itemBuilder: (context, i) {
          int idx = _homeController.myTransactions.length - i - 1;
          //делаем копию, чтобы перерисовать
          final transaction = _homeController.myTransactions[idx];
          final statusEmpty = transaction.status?.isEmpty ?? true;
          // final bool isIncome = transaction.type == 'Income' ? true : false;
          final text =
              '${transaction.date} ${transaction.operation} ${transaction.from} ${transaction.to} ${transaction.amount}';
          // final formatAmount = '- $text';
          return ListTile(
            title: Row(children: [
              Container(
                  // color: Colors.lightBlueAccent,
                  width: 190.w,
                  child: Text(
                      overflow: TextOverflow.ellipsis,
                      '${transaction.operation}')),
              // Text('${transaction.from}'),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 5.0)),
              Container(width: 50.w, child: Text('${transaction.amount}')),
            ]),
            subtitle:Column( children:[ Row(
              children: [
                Text('${transaction.date}'),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 5.0)),
                Container(width: 150.w, child: Text(/*transaction.type == 0 ? '${transaction.to}' :*/ '${transaction.from}')),
              ]),
              Text('${transaction.comment}', textAlign: TextAlign.left,),
            ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
            isThreeLine: true,
            dense: true,
              minLeadingWidth: 30,
              horizontalTitleGap: 0,
            leading: transaction.status?.isEmpty ?? true
            ? Icon(
                Icons.cancel,
                color: Colors.red,
              )
            : Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
            trailing: PopupMenuButton<int>(
              onSelected: (int? value) {
                if (value == 2) {
                  _homeController.deleteTransaction(idx);
                }
                if (value == 1) {
                  GoogleSheetsIntegration.addTransactionToGoogleSheets(
                          transaction)
                      .then((value) {
                    if (value) {
                      transaction.status = '1';
                      _homeController.updateTransaction(idx, transaction);
                    }
                  });
                }
              },
              itemBuilder: (BuildContext context) {
                var items = <PopupMenuEntry<int>>[
                  const PopupMenuItem<int>(
                    value: 2,
                    child: Text('Удалить'),
                  ),
                ];
                if (statusEmpty) {
                  items.insert(
                      1,
                      const PopupMenuItem<int>(
                        value: 1,
                        child: Text('Синхронизировать'),
                      ));
                }
                return items;
              },
            ),
            //tileColor: transaction.status?.isEmpty ?? true ? Colors.pink[100]! : null
          );
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
      );
    });
  }
}
