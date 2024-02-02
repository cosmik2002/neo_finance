import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:neo_finance/screens/add_transaction_screen2.dart';

import '../controllers/home_controller.dart';
import '../google_sheet_provider.dart';

class ExpenseList extends StatelessWidget {
  final _homeController = Get.find<HomeController>();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ModalProgressHUD(
        progressIndicator: const CircularProgressIndicator(),
        inAsyncCall:  _homeController.isInAsyncCall,
        child: ListView.separated(
          itemCount: _homeController.myTransactions.length,
          // reverse: true,
          separatorBuilder: (c, i) => const Divider(height: 0),
          itemBuilder: (context, i) {
            int idx = _homeController.myTransactions.length - i - 1;
            final transaction = _homeController.myTransactions[idx];
            final statusEmpty = transaction.status?.isEmpty ?? true;
            return ListTile(
              title: Row(children: [
                Container(
                    // color: Colors.lightBlueAccent,
                    width: 190.w,
                    child: Text(
                        overflow: TextOverflow.ellipsis,
                        '${transaction.operation}')),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 5.0)),
                Container(width: 50.w, child: Text('${transaction.amount}')),
              ]),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(transaction.date),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 5.0)),
                    Container(
                        width: 150.w,
                        child: Text(transaction.type == 0
                            ? transaction.to
                            : '${transaction.from}')
                    ),
                  ]),
                  Text(
                    '${transaction.comment}',
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
              isThreeLine: true,
              dense: true,
              minLeadingWidth: 30,
              horizontalTitleGap: 0,
              leading: statusEmpty
                  ? const Icon(
                      Icons.cancel,
                      color: Colors.red,
                    )
                  : const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
              trailing: PopupMenuButton<int>(
                onSelected: (int? value) async {
                  if (value == 2) {
                    _homeController.deleteTransaction(idx);
                  }
                  if (value == 1) {
                    GoogleSheetsIntegration.addTransactionToGoogleSheets(
                            transaction)
                        .then((value) {
                      if (value >= 0) {
                        transaction.row_number = value;
                        transaction.status = '1';
                        _homeController.updateTransaction(idx, transaction);
                      }
                    });
                  }
                  if(value == 3) {
                    bool check;
                    if(transaction.row_number != null) {
                      _homeController.isInAsyncCall = true;
                      check = await GoogleSheetsIntegration.checkTransactionToGoogleSheets(transaction, transaction.row_number!);
                      _homeController.isInAsyncCall = false;
                    } else {
                      check = true;
                    }
                    if(check) {
                      await Get.to(() => AddTransactionScreen2(), arguments: {'tm': transaction, 'idx': idx});
                    } else {
                      transaction.status = null;
                      _homeController.updateTransaction(idx, transaction);
                    }
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
                  // if(transaction.row_number != null) {
                    items.insert(
                        1,
                        const PopupMenuItem<int>(
                          value: 3,
                          child: Text('Редактировать'),
                        ));
                  // }
                  return items;
                },
              ),
            );
          },
        ),
      );
    });
  }
}
